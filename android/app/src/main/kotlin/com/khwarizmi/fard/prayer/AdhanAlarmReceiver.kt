package com.khwarizmi.fard.prayer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.util.Log
import androidx.core.content.ContextCompat

class AdhanAlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AdhanAlarmReceiver"
        private const val WAKELOCK_TAG = "fard:adhan_wakelock"
        private const val WAKELOCK_TIMEOUT_MS = 10 * 60 * 1000L // 10 minutes

        @Volatile
        var wakeLock: PowerManager.WakeLock? = null

        fun releaseWakeLock() {
            try {
                synchronized(this) {
                    wakeLock?.let {
                        if (it.isHeld) {
                            it.release()
                            Log.d(TAG, "WakeLock released successfully")
                        }
                    }
                    wakeLock = null
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error releasing WakeLock", e)
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        val now = System.currentTimeMillis()
        val scheduledTime = intent.getLongExtra("scheduledTime", 0L)
        if (scheduledTime != 0L) {
            val delayMs = now - scheduledTime
            Log.i(TAG, "onReceive: Adhan Alarm Triggered. Scheduled at ${java.util.Date(scheduledTime)}, Fired at ${java.util.Date(now)}, Delay = ${delayMs}ms")
        } else {
            Log.i(TAG, "onReceive: Adhan Alarm Triggered. Fired at ${java.util.Date(now)} (No scheduledTime extra found)")
        }

        // Acquire WakeLock immediately to ensure the device stays awake
        try {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            synchronized(AdhanAlarmReceiver::class.java) {
                if (wakeLock == null) {
                    wakeLock = powerManager.newWakeLock(
                        PowerManager.PARTIAL_WAKE_LOCK,
                        WAKELOCK_TAG
                    ).apply {
                        acquire(WAKELOCK_TIMEOUT_MS)
                    }
                    Log.d(TAG, "WakeLock acquired with 10 mins timeout")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error acquiring WakeLock", e)
        }

        val prayerName = intent.getStringExtra("prayerName") ?: ""
        val audioFilePath = intent.getStringExtra("audioFilePath") ?: ""
        val isAdhanAudioEnabled = intent.getBooleanExtra("isAdhanAudioEnabled", false)

        Log.d(TAG, "onReceive: prayerName=$prayerName, audioFilePath=$audioFilePath, isAdhanAudioEnabled=$isAdhanAudioEnabled")

        // Reschedule Adhan alarms to ensure next alarm is set (chain-of-custody)
        try {
            PrayerAlarmManager.scheduleAdhanAlarms(context)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to reschedule Adhan alarms on receive", e)
        }

        // CRITICAL: Always update persistent countdown notification immediately at prayer boundary zero-crossing
        // to prevent SystemUI Chronometer from displaying negative numbers past 00:00.
        try {
            CountdownNotificationManager.updateCountdownNotification(context)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to update countdown notification on adhan alarm", e)
        }

        // Start AdhanService as a Foreground Service ONLY if custom audio is enabled
        if (isAdhanAudioEnabled && audioFilePath.isNotEmpty()) {
            val serviceIntent = Intent(context, AdhanService::class.java).apply {
                putExtra("prayerName", prayerName)
                putExtra("audioFilePath", audioFilePath)
            }

            try {
                ContextCompat.startForegroundService(context, serviceIntent)
                Log.d(TAG, "AdhanService started successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start AdhanService (ForegroundServiceStartNotAllowedException on Android 14/15), releasing WakeLock and triggering notification fallback", e)
                releaseWakeLock()
            }
        } else {
            Log.d(TAG, "Boundary alarm triggered without custom Adhan audio, releasing WakeLock")
            releaseWakeLock()
        }
    }
}
