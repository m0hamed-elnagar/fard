package com.qada.fard.prayer

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.batoulapps.adhan.Prayer
import com.batoulapps.adhan.PrayerTimes
import com.qada.fard.PrayerWidgetReceiver
import java.util.*

object PrayerAlarmManager {
    private const val TAG = "PrayerAlarmManager"
    private const val REQUEST_CODE = 1001

    fun rescheduleAll(context: Context, prayerTimes: PrayerTimes) {
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
            else -> null // Next day handled by daily refresh
        }
    }

    private fun scheduleExactAlarm(context: Context, timeMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PrayerWidgetReceiver::class.java).apply {
            action = "com.qada.fard.UPDATE_WIDGET"
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
}
