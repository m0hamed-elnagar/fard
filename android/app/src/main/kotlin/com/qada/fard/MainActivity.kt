package com.qada.fard

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.glance.appwidget.updateAll
import com.qada.fard.prayer.CalculationContract
import com.qada.fard.prayer.PrayerAlarmManager
import com.qada.fard.prayer.PrayerTimesCalculator
import com.qada.fard.prayer.SettingsRepository
import com.qada.fard.prayer.PrayerParity
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : AudioServiceActivity() {
    private val TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Request exact alarm permission on Android 13+ if needed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            checkAndRequestExactAlarmPermission()
        }
    }

    /**
     * Check and request exact alarm permission on Android 13+.
     * This is required for precise countdown widget updates.
     */
    private fun checkAndRequestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w(TAG, "Exact alarm permission not granted - opening settings")
                // Open the exact alarm permission settings page
                try {
                    val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                    startActivity(intent)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to open exact alarm settings", e)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CalculationContract.CHANNEL_NAME).setMethodCallHandler { call, result ->
            if (call.method == "settingsChanged") {
                val settings = call.arguments as? Map<String, Any>
                Log.d(TAG, "Settings changed via MethodChannel: $settings")
                handleInstantSettingsUpdate(settings)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun handleInstantSettingsUpdate(settingsMap: Map<String, Any>?) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                // 1. Extract settings from the MethodChannel payload
                val latitude = (settingsMap?.get("latitude") as? Number)?.toDouble()
                val longitude = (settingsMap?.get("longitude") as? Number)?.toDouble()
                val calculationMethod = (settingsMap?.get("calculation_method") as? Number)?.toInt()
                val madhab = (settingsMap?.get("madhab") as? Number)?.toInt()
                val locale = settingsMap?.get("locale") as? String
                val prayerData = settingsMap?.get("prayer_data") as? String

                // Validate required settings
                if (latitude == null || longitude == null || calculationMethod == null || 
                    madhab == null || locale == null) {
                    Log.e(TAG, "Invalid settings received from Flutter: $settingsMap")
                    return@launch
                }

                // 2. Save settings to SharedPreferences FIRST
                val repository = SettingsRepository(this@MainActivity)
                repository.saveSettings(
                    latitude = latitude,
                    longitude = longitude,
                    calculationMethod = calculationMethod,
                    madhab = madhab,
                    locale = locale,
                    prayerData = prayerData
                )
                Log.d(TAG, "Settings saved to SharedPreferences")

                // 3. Invalidate Kotlin calculation cache
                PrayerTimesCalculator.invalidateCache()

                // 4. Read settings from SharedPreferences (now guaranteed to exist)
                val settings = repository.getSettings() ?: run {
                    Log.e(TAG, "Failed to read settings after saving")
                    return@launch
                }

                // 5. Perform a fresh calculation
                val prayerTimes = PrayerTimesCalculator.calculateToday(settings)

                // 6. Parity check (debug only)
                // val dartTimes = settingsMap?.get("prayer_times") as? Map<String, Any>
                // if (dartTimes != null) {
                //     PrayerParity.assert(dartTimes, prayerTimes)
                // }

                // 7. Reschedule all alarms for the new calculation
                PrayerAlarmManager.rescheduleAll(this@MainActivity, prayerTimes)

                // 8. Update UI on Main thread and send broadcasts
                withContext(Dispatchers.Main) {
                    // Refresh 1: Immediate re-render attempt
                    PrayerWidget().updateAll(this@MainActivity)
                    NextPrayerCountdownWidget().updateAll(this@MainActivity)

                    // Delay slightly to let SharedPreferences commit settle
                    kotlinx.coroutines.delay(100)

                    // Refresh 2: Picking up fresh data from disk
                    PrayerWidget().updateAll(this@MainActivity)
                    NextPrayerCountdownWidget().updateAll(this@MainActivity)

                    // Robust update via Receivers (handles alarms, etc)
                    val prayerIntent = Intent(this@MainActivity, PrayerWidgetReceiver::class.java).apply {
                        action = "com.qada.fard.UPDATE_WIDGET"
                    }
                    sendBroadcast(prayerIntent)

                    val countdownIntent = Intent(this@MainActivity, NextPrayerCountdownWidgetReceiver::class.java).apply {
                        action = "com.qada.fard.ACTION_FORCE_UPDATE"
                    }
                    sendBroadcast(countdownIntent)

                    // 9. Absolute safety net: Enqueue OneTimeWorkRequest to refresh widgets from background
                    try {
                        val workRequest = androidx.work.OneTimeWorkRequestBuilder<com.qada.fard.widget.WidgetUpdateWorker>()
                            .setExpedited(androidx.work.OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                            .build()
                        androidx.work.WorkManager.getInstance(this@MainActivity).enqueue(workRequest)
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to enqueue expedited work, falling back to normal", e)
                        val workRequest = androidx.work.OneTimeWorkRequestBuilder<com.qada.fard.widget.WidgetUpdateWorker>().build()
                        androidx.work.WorkManager.getInstance(this@MainActivity).enqueue(workRequest)
                    }
                }
                Log.d(TAG, "Widgets updated (double-refresh), broadcasts sent, and WorkManager task enqueued")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to handle settings update", e)
            }
        }
    }
}
