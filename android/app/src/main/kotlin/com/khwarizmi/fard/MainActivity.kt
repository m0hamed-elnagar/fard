package com.khwarizmi.fard

import android.content.ComponentName
import java.util.Locale
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.glance.appwidget.updateAll
import androidx.core.content.FileProvider
import com.khwarizmi.fard.prayer.CalculationContract
import com.khwarizmi.fard.prayer.PrayerAlarmManager
import com.khwarizmi.fard.prayer.PrayerTimesCalculator
import com.khwarizmi.fard.prayer.SettingsRepository
import com.khwarizmi.fard.prayer.PrayerParity
import com.khwarizmi.fard.prayer.AdhanService
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val TAG = "MainActivity"
    
    // MethodChannel for widget theme persistence (constructed dynamically based on package name)
    private val widgetThemeChannelName: String
        get() = "$packageName/widget_theme"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            Log.d(TAG, "handleIntent: checking if STOP_ADHAN_ON_OPEN is set")
            if (it.getBooleanExtra("STOP_ADHAN_ON_OPEN", false)) {
                Log.d(TAG, "handleIntent: STOP_ADHAN_ON_OPEN is true, stopping AdhanService")
                try {
                    val stopIntent = Intent(this, AdhanService::class.java).apply {
                        action = "$packageName.action.STOP_ADHAN"
                    }
                    startService(stopIntent)
                } catch (e: Exception) {
                    Log.e(TAG, "Error stopping AdhanService via handleIntent", e)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Adhan alarms reschedule channel
        val adhanChannelName = "$packageName/adhan"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, adhanChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "rescheduleAdhanAlarms" -> {
                    Log.d(TAG, "MethodChannel rescheduleAdhanAlarms called")
                    try {
                        PrayerAlarmManager.scheduleAdhanAlarms(this)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error in rescheduleAdhanAlarms channel call", e)
                        result.error("SCHEDULING_FAILED", e.message, null)
                    }
                }
                "startAdhanService" -> {
                    val prayerName = call.argument<String>("prayerName") ?: "تجربة"
                    val audioFilePath = call.argument<String>("audioFilePath") ?: ""
                    val isTest = call.argument<Boolean>("isTest") ?: false
                    Log.d(TAG, "MethodChannel startAdhanService called: prayerName=$prayerName, audioFilePath=$audioFilePath, isTest=$isTest")
                    try {
                        val intent = Intent(this, AdhanService::class.java).apply {
                            putExtra("prayerName", prayerName)
                            putExtra("audioFilePath", audioFilePath)
                            putExtra("isTest", isTest)
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error in startAdhanService channel call", e)
                        result.error("PLAYBACK_FAILED", e.message, null)
                    }
                }
                "stopAdhanService" -> {
                    Log.d(TAG, "MethodChannel stopAdhanService called")
                    try {
                        val intent = Intent(this, AdhanService::class.java).apply {
                            action = "$packageName.action.STOP_ADHAN"
                        }
                        startService(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error in stopAdhanService channel call", e)
                        result.error("STOP_FAILED", e.message, null)
                    }
                }
                "getDeviceManufacturer" -> {
                    result.success(Build.MANUFACTURER.lowercase(Locale.getDefault()))
                }
                "openAutostartSettings" -> {
                    openAutostartSettings()
                    result.success(true)
                }
                "isBatteryOptimizationIgnored" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    result.success(powerManager.isIgnoringBatteryOptimizations(packageName))
                }
                "requestIgnoreBatteryOptimizations" -> {
                    try {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.fromParts("package", packageName, null)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error in requestIgnoreBatteryOptimizations", e)
                        result.error("INTENT_FAILED", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Original settings channel (dynamic using packageName)
        val settingsChannelName = "$packageName/instant_updates"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, settingsChannelName).setMethodCallHandler { call, result ->
            if (call.method == "settingsChanged") {
                val settings = call.arguments as? Map<String, Any>
                Log.d(TAG, "=== SETTINGS CHANGED VIA METHOD CHANNEL ===")
                Log.d(TAG, "Settings payload: $settings")
                Log.d(TAG, "Prayer data present: ${settings?.containsKey("prayer_data")}")
                handleInstantSettingsUpdate(settings)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
            
        // Widget theme persistence channel
        val widgetThemeChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            widgetThemeChannelName
        )
        widgetThemeChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "saveWidgetTheme" -> {
                    val args = call.arguments<Map<String, Any>>()
                    if (args != null) {
                        try {
                            val repository = SettingsRepository(this)
                            repository.saveWidgetTheme(args)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Arguments are null", null)
                    }
                }
                "getWidgetTheme" -> {
                    try {
                        val repository = SettingsRepository(this)
                        val theme = repository.getWidgetTheme()
                        // Convert custom object to map for serialization over MethodChannel
                        val themeMap = mapOf(
                            "primaryColorHex" to theme.primaryColorHex,
                            "accentColorHex" to theme.accentColorHex,
                            "backgroundColorHex" to theme.backgroundColorHex,
                            "surfaceColorHex" to theme.surfaceColorHex,
                            "textColorHex" to theme.textColorHex,
                            "textSecondaryColorHex" to theme.textSecondaryColorHex
                        )
                        result.success(themeMap)
                    } catch (e: Exception) {
                        result.error("GET_FAILED", e.message, null)
                    }
                }
                "applyWidgetTheme" -> {
                    // Save theme and trigger widget update
                    val args = call.arguments<Map<*, *>>()
                    if (args != null) {
                        Log.d(TAG, "=== APPLY WIDGET THEME CALLED ===")
                        Log.d(TAG, "Received theme: $args")
                        
                        CoroutineScope(Dispatchers.Main).launch {
                            try {
                                val repository = SettingsRepository(this@MainActivity)
                                
                                // Robust color parsing
                                val colors = mutableMapOf<String, String>()
                                args.forEach { (key, value) ->
                                    if (key is String && value is String) {
                                        colors[key] = value
                                    }
                                }
                                
                                if (colors.isNotEmpty()) {
                                    repository.saveWidgetTheme(colors)
                                }
                                
                                // Verify saved theme
                                val savedTheme = repository.getWidgetTheme()
                                Log.d(TAG, "Saved theme from SharedPreferences: $savedTheme")
                                
                                // Small delay to ensure commit has settled
                                kotlinx.coroutines.delay(100)

                                // Trigger Widget Refresh
                                triggerWidgetUpdates()
                                
                                result.success(true)
                            } catch (e: Exception) {
                                Log.e(TAG, "Error applying widget theme: $e")
                                result.error("THEME_ERROR", e.message, null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGS", "Arguments are null", null)
                    }
                }

                "clearWidgetTheme" -> {
                    Log.d(TAG, "=== CLEAR WIDGET THEME CALLED ===")
                    val triggerUpdate = call.argument<Boolean>("trigger_update") ?: true
                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            val repository = SettingsRepository(this@MainActivity)
                            repository.clearWidgetTheme()
                            
                            if (triggerUpdate) {
                                // Small delay to ensure commit has settled
                                kotlinx.coroutines.delay(100)

                                // Trigger Widget Refresh to revert to dynamic colors
                                triggerWidgetUpdates()
                            }
                            
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error clearing widget theme: $e")
                            result.error("THEME_ERROR", e.message, null)
                        }
                    }
                }
                "grantUriPermission" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        try {
                            val uri = android.net.Uri.parse(uriString)
                            // Grant permission to system packages
                            grantUriPermission("com.android.systemui", uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            grantUriPermission("android", uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error granting URI permission: $e")
                            result.error("URI_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "URI is null", null)
                    }
                }
                "getNotificationSoundUri" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        val file = File(filePath)
                        if (file.exists()) {
                            try {
                                val authority = "${context.packageName}.fileprovider"
                                val uri = FileProvider.getUriForFile(context, authority, file)
                                
                                // Grant permissions explicitly to system UI and Android system server
                                // We use both FLAG_GRANT_READ_URI_PERMISSION and FLAG_GRANT_PERSISTABLE_URI_PERMISSION if possible
                                val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                                context.grantUriPermission("com.android.systemui", uri, flags)
                                context.grantUriPermission("android", uri, flags)
                                context.grantUriPermission("com.google.android.deskclock", uri, flags) // Some devices use this for alarms
                                
                                Log.d(TAG, "getNotificationSoundUri: Resolved URI and granted permissions for $filePath: $uri")
                                result.success(uri.toString())
                            } catch (e: Exception) {
                                Log.e(TAG, "getNotificationSoundUri error", e)
                                result.error("URI_ERROR", e.message, null)
                            }
                        } else {
                            result.error("FILE_NOT_FOUND", "File does not exist: $filePath", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Helper to trigger updates for all Glance widgets.
     */
    private suspend fun triggerWidgetUpdates() {
        Log.d(TAG, "Refreshing PrayerWidget & CountdownWidget...")
        PrayerWidget().updateAll(this@MainActivity)
        NextPrayerCountdownWidget().updateAll(this@MainActivity)

        // Android 15+ Picker Preview synchronization
        if (Build.VERSION.SDK_INT >= 35) { // Build.VERSION_CODES.VANILLA_ICE_CREAM
            try {
                val manager = androidx.glance.appwidget.GlanceAppWidgetManager(this@MainActivity)
                val p1 = manager.setWidgetPreviews(receiver = PrayerWidgetReceiver::class)
                val p2 = manager.setWidgetPreviews(receiver = NextPrayerCountdownWidgetReceiver::class)
                Log.d(TAG, "Android 15+ widget previews synchronized (Results: $p1, $p2)")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to synchronize widget previews", e)
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
                val hijriDate = settingsMap?.get("hijri_date") as? String
                
                // Validate required settings
                if (latitude == null || longitude == null || calculationMethod == null ||
                    madhab == null || locale == null) {
                    Log.e(TAG, "CRITICAL: Missing required settings! lat=$latitude, lon=$longitude, method=$calculationMethod, madhab=$madhab, locale=$locale")
                    return@launch
                }

                // 2. Save settings to SharedPreferences FIRST
                val repository = SettingsRepository(this@MainActivity)
                Log.d(TAG, "Saving settings to repository...")
                repository.saveSettings(
                    latitude = latitude,
                    longitude = longitude,
                    calculationMethod = calculationMethod,
                    madhab = madhab,
                    locale = locale,
                    prayerData = prayerData,
                    hijriDate = hijriDate
                )

                // 2.1 Explicitly sync app theme to widget theme keys if not manual
                if (prayerData != null) {
                    val appTheme = com.khwarizmi.fard.widget.WidgetParser.parseTheme(prayerData)
                    repository.syncAppTheme(appTheme)
                }

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
                    Log.d(TAG, "Updating PrayerWidget...")
                    PrayerWidget().updateAll(this@MainActivity)
                    Log.d(TAG, "Updating NextPrayerCountdownWidget...")
                    NextPrayerCountdownWidget().updateAll(this@MainActivity)

                    // Delay slightly to let SharedPreferences commit settle
                    kotlinx.coroutines.delay(100)

                    // Refresh 2: Picking up fresh data from disk
                    Log.d(TAG, "Second update attempt - PrayerWidget...")
                    PrayerWidget().updateAll(this@MainActivity)
                    Log.d(TAG, "Second update attempt - NextPrayerCountdownWidget...")
                    NextPrayerCountdownWidget().updateAll(this@MainActivity)
                    Log.d(TAG, "All widget updates completed")

                    // Robust update via Receivers (handles alarms, etc)
                    val prayerIntent = Intent(this@MainActivity, PrayerWidgetReceiver::class.java).apply {
                        action = "${packageName}.UPDATE_WIDGET"
                    }
                    sendBroadcast(prayerIntent)

                    val countdownIntent = Intent(this@MainActivity, NextPrayerCountdownWidgetReceiver::class.java).apply {
                        action = "${packageName}.ACTION_FORCE_UPDATE"
                    }
                    sendBroadcast(countdownIntent)

                    // 9. Absolute safety net: Enqueue OneTimeWorkRequest to refresh widgets from background
                    try {
                        val workRequest = androidx.work.OneTimeWorkRequestBuilder<com.khwarizmi.fard.widget.WidgetUpdateWorker>()
                            .setExpedited(androidx.work.OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                            .build()
                        androidx.work.WorkManager.getInstance(this@MainActivity).enqueue(workRequest)
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to enqueue expedited work, falling back to normal", e)
                        val workRequest = androidx.work.OneTimeWorkRequestBuilder<com.khwarizmi.fard.widget.WidgetUpdateWorker>().build()
                        androidx.work.WorkManager.getInstance(this@MainActivity).enqueue(workRequest)
                    }
                }
                Log.d(TAG, "Widgets updated (double-refresh), broadcasts sent, and WorkManager task enqueued")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to handle settings update", e)
            }
        }
    }

    private fun openAutostartSettings() {
        val manufacturer = Build.MANUFACTURER.lowercase(Locale.getDefault())
        val intents = mutableListOf<Intent>()

        when {
            manufacturer.contains("xiaomi") || manufacturer.contains("redmi") || manufacturer.contains("poco") -> {
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.miui.securitycenter",
                        "com.miui.permcenter.autostart.AutoStartManagementActivity"
                    )
                })
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.miui.securitycenter",
                        "com.miui.securitycenter.permission.AutoStartManagementActivity"
                    )
                })
                intents.add(Intent("miui.intent.action.OP_AUTO_START").apply {
                    addCategory(Intent.CATEGORY_DEFAULT)
                })
            }
            manufacturer.contains("huawei") || manufacturer.contains("honor") -> {
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
                    )
                })
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity"
                    )
                })
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.optimize.process.ProtectActivity"
                    )
                })
            }
            manufacturer.contains("oppo") || manufacturer.contains("realme") -> {
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.permission.startup.StartupAppListActivity"
                    )
                })
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.startupapp.StartupAppListActivity"
                    )
                })
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.oppo.safe",
                        "com.oppo.safe.permission.startup.StartupAppListActivity"
                    )
                })
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.permission.startupapp.StartupAppListActivity"
                    )
                })
            }
            manufacturer.contains("vivo") -> {
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.vivo.permissionmanager",
                        "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
                    )
                })
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.iqoo.secure",
                        "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager"
                    )
                })
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.iqoo.secure",
                        "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"
                    )
                })
            }
            manufacturer.contains("oneplus") -> {
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.oneplus.security",
                        "com.oneplus.security.chainlaunch.AppBootLaunchActivity"
                    )
                })
                // OnePlus fallback to Oppo/ColorOS paths (common in Android 12+)
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.permission.startup.StartupAppListActivity"
                    )
                })
                intents.add(Intent().apply {
                    component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.startupapp.StartupAppListActivity"
                    )
                })
            }
        }

        var success = false
        for (intent in intents) {
            try {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                success = true
                Log.d(TAG, "Successfully started autostart activity: ${intent.component ?: intent.action}")
                break
            } catch (e: Exception) {
                Log.w(TAG, "Failed to start autostart activity variant, trying next: ${intent.component ?: intent.action}", e)
            }
        }

        if (!success) {
            Log.i(TAG, "No specific autostart activity succeeded. Falling back to App settings.")
            try {
                val fallbackIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = android.net.Uri.fromParts("package", packageName, null)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(fallbackIntent)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start fallback app settings details", e)
            }
        }
    }
}

