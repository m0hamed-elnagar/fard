package com.qada.fard.widget

import android.content.Context
import android.util.Log
import androidx.glance.appwidget.updateAll
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import android.content.Intent
import com.qada.fard.PrayerWidget
import com.qada.fard.NextPrayerCountdownWidgetReceiver

class WidgetUpdateWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        Log.d("WidgetUpdateWorker", "Safety net worker running - updating widgets")
        
        return try {
            // Update the main PrayerWidget directly
            PrayerWidget().updateAll(applicationContext)
            
            // For the CountdownWidget, send a broadcast to the receiver
            // This ensures the minute-loop is restarted if it died
            val intent = Intent(applicationContext, NextPrayerCountdownWidgetReceiver::class.java).apply {
                action = NextPrayerCountdownWidgetReceiver.ACTION_FORCE_UPDATE
            }
            applicationContext.sendBroadcast(intent)
            
            Result.success()
        } catch (e: Exception) {
            Log.e("WidgetUpdateWorker", "Failed to update widgets", e)
            Result.retry()
        }
    }
}
