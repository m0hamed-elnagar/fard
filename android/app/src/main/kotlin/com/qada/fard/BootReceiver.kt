package com.qada.fard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.glance.appwidget.updateAll
import com.qada.fard.prayer.PrayerAlarmManager
import com.qada.fard.prayer.PrayerTimesCalculator
import com.qada.fard.prayer.SettingsRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        
        Log.i("BootReceiver", "BOOT_COMPLETED received - refreshing widgets and alarms")

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
    }
}
