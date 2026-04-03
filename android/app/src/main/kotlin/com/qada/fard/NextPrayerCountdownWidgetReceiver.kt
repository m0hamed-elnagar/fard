package com.qada.fard

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.updateAll
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.util.Calendar

class NextPrayerCountdownWidgetReceiver : GlanceAppWidgetReceiver() {

    override val glanceAppWidget: GlanceAppWidget = NextPrayerCountdownWidget()

    // Dedicated scope for this receiver instance
    private val receiverScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onReceive(context: Context, intent: Intent) {
        // Standard Glance actions are handled by super.onReceive()
        super.onReceive(context, intent)

        Log.d("CountdownWidgetRec", "onReceive: ${intent.action}")

        when (intent.action) {
            ACTION_FORCE_UPDATE,
            ACTION_MINUTE_UPDATE,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_USER_PRESENT,
            "android.intent.action.TIME_SET",
            "android.intent.action.TIMEZONE_CHANGED" -> {
                updateAndSchedule(context)
            }
        }
    }

    private fun updateAndSchedule(context: Context) {
        receiverScope.launch {
            try {
                glanceAppWidget.updateAll(context)
                Log.d("CountdownWidgetRec", "Widget updated successfully")
            } catch (e: Exception) {
                Log.e("CountdownWidgetRec", "Update failed", e)
            } finally {
                scheduleNextMinuteUpdate(context)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        scheduleNextMinuteUpdate(context)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d("CountdownWidgetRec", "Widget enabled — starting minute updates")
        scheduleNextMinuteUpdate(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        receiverScope.cancel()
        cancelMinuteUpdate(context)
        Log.d("CountdownWidgetRec", "Last widget removed — cancelled updates")
    }

    private fun scheduleNextMinuteUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, NextPrayerCountdownWidgetReceiver::class.java).apply {
            action = ACTION_MINUTE_UPDATE
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            MINUTE_UPDATE_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Target the start of the NEXT minute
        val calendar = Calendar.getInstance().apply {
            add(Calendar.MINUTE, 1)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && alarmManager.canScheduleExactAlarms()) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                // Fallback for older versions or missing permission
                alarmManager.set(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            }
            Log.d("CountdownWidgetRec", "Scheduled next minute update for: ${calendar.time}")
        } catch (e: Exception) {
            Log.e("CountdownWidgetRec", "Failed to schedule alarm", e)
        }
    }

    private fun cancelMinuteUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, NextPrayerCountdownWidgetReceiver::class.java).apply {
            action = ACTION_MINUTE_UPDATE
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            MINUTE_UPDATE_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }
    }

    companion object {
        const val ACTION_FORCE_UPDATE = "com.qada.fard.ACTION_FORCE_UPDATE"
        const val ACTION_MINUTE_UPDATE = "com.qada.fard.ACTION_MINUTE_UPDATE"
        private const val MINUTE_UPDATE_REQUEST_CODE = 2001
    }
}
