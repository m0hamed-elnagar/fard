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

class TimeChangedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("TimeChangedReceiver", "Time change broadcast received: ${intent.action}")

        val pendingResult = goAsync()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                updateAll(context)
                
                // 🛡️ Trigger Flutter side to reschedule Azan notifications immediately
                val workRequest = androidx.work.OneTimeWorkRequestBuilder<com.qada.fard.widget.WidgetUpdateWorker>()
                    .addTag("time_change_reschedule")
                    .build()
                
                // Use the same key as Flutter Workmanager for the main task
                androidx.work.WorkManager.getInstance(context).enqueueUniqueWork(
                    "prayer_scheduler_task_name",
                    androidx.work.ExistingWorkPolicy.REPLACE,
                    workRequest
                )
            } finally {
                pendingResult.finish()
            }
        }
    }

    private suspend fun updateAll(context: Context) {
        val repository = SettingsRepository(context)
        val settings = repository.getSettings() ?: return
        
        // Clear cache since time/timezone changed
        PrayerTimesCalculator.invalidateCache()
        val prayerTimes = PrayerTimesCalculator.calculateToday(settings)
        
        // Reschedule alarms
        PrayerAlarmManager.rescheduleAll(context, prayerTimes)
        
        // Update UIs
        PrayerWidget().updateAll(context)
        NextPrayerCountdownWidget().updateAll(context)
    }
}
