package com.khwarizmi.fard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.glance.appwidget.updateAll
import com.khwarizmi.fard.prayer.CountdownNotificationManager
import com.khwarizmi.fard.prayer.PrayerAlarmManager
import com.khwarizmi.fard.prayer.PrayerTimesCalculator
import com.khwarizmi.fard.prayer.SettingsRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED && 
            intent.action != Intent.ACTION_LOCKED_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        
        Log.i("BootReceiver", "BOOT_COMPLETED / LOCKED_BOOT_COMPLETED / MY_PACKAGE_REPLACED received - refreshing widgets and alarms")

        val pendingResult = goAsync()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                updateAll(context)
            } finally {
                pendingResult.finish()
            }
        }
    }

    private suspend fun updateAll(context: Context) {
        val repository = SettingsRepository(context)
        val settings = repository.getSettings() ?: return

        val prayerTimes = PrayerTimesCalculator.calculateToday(settings)

        // Reschedule all alarms because they were cleared on reboot
        PrayerAlarmManager.rescheduleAll(context, prayerTimes)

        // Refresh UIs
        PrayerWidget().updateAll(context)
        NextPrayerCountdownWidget().updateAll(context)
        
        // Update countdown notification
        try {
            CountdownNotificationManager.updateCountdownNotification(context)
        } catch (e: Exception) {
            Log.e("BootReceiver", "Failed to update countdown notification", e)
        }
        
        // IMPORTANT: Restart the countdown widget's minute-by-minute update loop
        // This was missing after reboot, causing the countdown to stop updating
        NextPrayerCountdownWidgetReceiver().scheduleNextMinuteUpdate(context)
        
        Log.i("BootReceiver", "All widgets and alarms refreshed")
    }
}

