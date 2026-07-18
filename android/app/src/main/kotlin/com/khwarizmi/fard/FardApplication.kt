package com.khwarizmi.fard

import android.app.Application
import android.content.Context
import android.util.Log
import androidx.work.*
import com.khwarizmi.fard.widget.WidgetUpdateWorker
import java.util.concurrent.TimeUnit

class FardApplication : Application() {
    
    companion object {
        private const val TAG = "FardApplication"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Application onCreate")

        // Migrate notifications cache on process startup to fix/prevent setSmallIcon NPE
        migrateNotificationsCache()

        // Schedule WorkManager safety net (15-min periodic)
        scheduleWidgetSafetyNet()
    }

    private fun migrateNotificationsCache() {
        try {
            // 1. Fix defaultIcon in notification_plugin_cache if missing or empty
            val pluginPrefs = getSharedPreferences("notification_plugin_cache", Context.MODE_PRIVATE)
            val defaultIcon = pluginPrefs.getString("defaultIcon", null)
            if (defaultIcon.isNullOrEmpty()) {
                pluginPrefs.edit().putString("defaultIcon", "@mipmap/ic_launcher").apply()
                Log.i(TAG, "Migrated defaultIcon in notification_plugin_cache to @mipmap/ic_launcher")
            }

            // 2. Fix icon parameter in scheduled_notifications JSON payload
            val sharedPrefs = getSharedPreferences("scheduled_notifications", Context.MODE_PRIVATE)
            val jsonStr = sharedPrefs.getString("scheduled_notifications", null)
            if (!jsonStr.isNullOrEmpty()) {
                var modified = false
                val jsonArray = org.json.JSONArray(jsonStr)
                for (i in 0 until jsonArray.length()) {
                    val obj = jsonArray.getJSONObject(i)
                    // If the icon field is missing or null, set it to the default launcher icon
                    if (!obj.has("icon") || obj.isNull("icon") || obj.optString("icon").isEmpty()) {
                        obj.put("icon", "@mipmap/ic_launcher")
                        modified = true
                    }
                }
                if (modified) {
                    sharedPrefs.edit().putString("scheduled_notifications", jsonArray.toString()).apply()
                    Log.i(TAG, "Migrated scheduled_notifications JSON cache with default icon")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to migrate notifications cache: $e")
        }
    }

    private fun scheduleWidgetSafetyNet() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
            .build()

        val workRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(15, TimeUnit.MINUTES)
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "widget_safety_net",
            ExistingPeriodicWorkPolicy.REPLACE,  // Always use latest configuration
            workRequest
        )
        Log.d(TAG, "Scheduled 15-min safety net worker")
    }
}

