package com.qada.fard

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.updateAll
import com.qada.fard.prayer.PrayerAlarmManager
import com.qada.fard.prayer.PrayerTimesCalculator
import com.qada.fard.prayer.SettingsRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.SupervisorJob

class PrayerWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = PrayerWidget()
    
    private val receiverScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onReceive(context: Context, intent: Intent) {
        // super.onReceive handles standard Glance/AppWidget broadcasts asynchronously
        super.onReceive(context, intent)

        val action = intent.action
        Log.d("PrayerWidgetReceiver", "onReceive: $action")

        when (action) {
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_LOCALE_CHANGED,
            Intent.ACTION_BOOT_COMPLETED,
            "com.qada.fard.UPDATE_WIDGET" -> {
                receiverScope.launch {
                    updateAll(context)
                }
            }
        }
    }

    private suspend fun updateAll(context: Context) {
        try {
            val repository = SettingsRepository(context)
            val settings = repository.getSettings() ?: run {
                Log.w("PrayerWidgetReceiver", "No settings available, skipping update")
                return
            }

            val prayerTimes = PrayerTimesCalculator.calculateToday(settings)

            // Reschedule alarm for the next prayer transition
            PrayerAlarmManager.rescheduleAll(context, prayerTimes)

            // Update the actual UI
            glanceAppWidget.updateAll(context)
            Log.d("PrayerWidgetReceiver", "Widget updated successfully")
        } catch (e: Exception) {
            Log.e("PrayerWidgetReceiver", "Error updating widget", e)
        }
    }
}
