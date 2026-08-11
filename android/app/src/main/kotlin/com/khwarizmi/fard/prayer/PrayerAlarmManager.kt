package com.khwarizmi.fard.prayer

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.batoulapps.adhan.Prayer
import com.batoulapps.adhan.PrayerTimes
import com.khwarizmi.fard.PrayerWidgetReceiver
import com.khwarizmi.fard.MainActivity
import org.json.JSONArray
import java.util.*

object PrayerAlarmManager {
    private const val TAG = "PrayerAlarmManager"
    private const val REQUEST_CODE = 1001
    private const val BASE_ADHAN_REQUEST_CODE = 3000

    fun rescheduleAll(context: Context, prayerTimes: PrayerTimes) {
        // Reschedule Adhan alarms independently of widget alarm
        scheduleAdhanAlarms(context)

        val nextPrayer = getNextPrayer(prayerTimes) ?: return
        val nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer) ?: return
        
        scheduleExactAlarm(context, nextPrayerTime.time)
    }

    private fun getNextPrayer(prayerTimes: PrayerTimes): Prayer? {
        val now = Date()
        return when {
            prayerTimes.fajr.after(now) -> Prayer.FAJR
            prayerTimes.dhuhr.after(now) -> Prayer.DHUHR
            prayerTimes.asr.after(now) -> Prayer.ASR
            prayerTimes.maghrib.after(now) -> Prayer.MAGHRIB
            prayerTimes.isha.after(now) -> Prayer.ISHA
            else -> Prayer.FAJR // Next day Fajr fallback
        }
    }

    private fun scheduleExactAlarm(context: Context, timeMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PrayerWidgetReceiver::class.java).apply {
            action = "${context.packageName}.UPDATE_WIDGET"
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (canScheduleExactAlarms(context)) {
            Log.d(TAG, "Scheduling exact alarm for ${Date(timeMillis)}")
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                timeMillis,
                pendingIntent
            )
        } else {
            Log.d(TAG, "Exact alarms not permitted, falling back to setWindow")
            alarmManager.setWindow(
                AlarmManager.RTC_WAKEUP,
                timeMillis - 60_000,
                120_000,
                pendingIntent
            )
        }
    }

    private fun canScheduleExactAlarms(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).canScheduleExactAlarms()
        } else true
    }

    private fun getPrayerIndex(prayerName: String): Int {
        return when (prayerName) {
            "الفجر" -> 0
            "الظهر" -> 1
            "العصر" -> 2
            "المغرب" -> 3
            "العشاء" -> 4
            else -> -1
        }
    }

    /**
     * CRITICAL: We must ALWAYS schedule boundary alarms for ALL upcoming prayers (timeEpochMs > now),
     * regardless of whether custom Adhan audio is enabled (`enabled`).
     * If alarms are skipped when enabled is false, CountdownNotificationManager will not be updated
     * at prayer zero-crossing, causing Android SystemUI Chronometer to count past 00:00 into negative numbers.
     */
    fun scheduleAdhanAlarms(context: Context) {
        Log.d(TAG, "scheduleAdhanAlarms started")
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val jsonStr = prefs.getString("flutter.fard.adhan_schedule", null)
            ?: prefs.getString("fard.adhan_schedule", null)

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // Cancel slots 0 to 19 to clean up any leftover/outdated alarms
        for (slot in 0..19) {
            val requestCode = BASE_ADHAN_REQUEST_CODE + slot
            val intent = Intent(context, AdhanAlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_NO_CREATE or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
                Log.d(TAG, "Cancelled leftover Adhan alarm at slot $slot")
            }
        }

        if (jsonStr == null) {
            Log.w(TAG, "No Adhan schedule JSON found in SharedPreferences.")
            return
        }

        try {
            val jsonArray = JSONArray(jsonStr)
            val now = System.currentTimeMillis()

            for (i in 0 until jsonArray.length()) {
                try {
                    val item = jsonArray.getJSONObject(i)
                    val prayerName = item.optString("prayerName", "")
                    val timeEpochMs = item.optLong("timeEpochMs", 0L)
                    val audioFilePath = item.optString("audioFilePath", "")
                    val enabled = item.optBoolean("enabled", false)
                    
                    // Retrieve useExactAlarmClock preference (checking item json first, then fallback to prefs)
                    val useExactAlarmClockJson = item.optBoolean("useExactAlarmClock", true)
                    val useExactAlarmClockPrefs = prefs.getBoolean("flutter.use_exact_alarm_clock", true)
                    val useExactSetting = useExactAlarmClockJson && useExactAlarmClockPrefs

                    val prayerIndex = getPrayerIndex(prayerName)
                    if (prayerIndex == -1 || timeEpochMs == 0L) {
                        continue
                    }

                    val requestCode = BASE_ADHAN_REQUEST_CODE + i

                    // Create intent targeting AdhanAlarmReceiver
                    val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
                        putExtra("prayerName", prayerName)
                        putExtra("audioFilePath", audioFilePath)
                        putExtra("isAdhanAudioEnabled", enabled)
                        putExtra("scheduledTime", timeEpochMs) // Pass expected scheduled time for trigger delay analysis
                    }

                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        requestCode,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
                    )

                    if (timeEpochMs > now) {
                        val hasExactPermission = canScheduleExactAlarms(context)
                        val useExact = useExactSetting && hasExactPermission

                        if (useExact) {
                            Log.d(TAG, "Scheduling boundary/Adhan alarm for $prayerName at ${Date(timeEpochMs)} using setAlarmClock (RequestCode: $requestCode, audioEnabled: $enabled)")
                            val showIntent = Intent(context, MainActivity::class.java)
                            val showPendingIntent = PendingIntent.getActivity(
                                context,
                                0,
                                showIntent,
                                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
                            )
                            val alarmClockInfo = AlarmManager.AlarmClockInfo(timeEpochMs, showPendingIntent)
                            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
                        } else {
                            Log.d(TAG, "Scheduling boundary/Adhan alarm for $prayerName at ${Date(timeEpochMs)} using fallback setAndAllowWhileIdle (RequestCode: $requestCode, audioEnabled: $enabled)")
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                alarmManager.setAndAllowWhileIdle(
                                    AlarmManager.RTC_WAKEUP,
                                    timeEpochMs,
                                    pendingIntent
                                )
                            } else {
                                alarmManager.set(
                                    AlarmManager.RTC_WAKEUP,
                                    timeEpochMs,
                                    pendingIntent
                                )
                            }
                        }
                    } else {
                        Log.d(TAG, "Boundary/Adhan alarm for $prayerName at ${Date(timeEpochMs)} is in the past.")
                    }
                } catch (slotEx: Exception) {
                    Log.e(TAG, "Error scheduling individual Adhan alarm slot $i", slotEx)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing or scheduling Adhan alarms", e)
        }
    }
}
