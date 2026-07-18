package com.khwarizmi.fard

import android.app.AlarmManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.khwarizmi.fard.prayer.PrayerAlarmManager
import com.khwarizmi.fard.prayer.PrayerTimesCalculator
import com.khwarizmi.fard.prayer.SettingsRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class ExactAlarmPermissionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED) return
        
        Log.i("ExactAlarmReceiver", "Exact alarm permission changed")

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val hasExactPermission = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }

        if (!hasExactPermission) {
            Log.w("ExactAlarmReceiver", "Exact alarm permission was revoked! Auto-disabling use_exact_alarm_clock setting.")
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            prefs.edit().putBoolean("flutter.use_exact_alarm_clock", false).commit()
        }

        val pendingResult = goAsync()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                rescheduleAlarms(context)
            } finally {
                pendingResult.finish()
            }
        }
    }

    private suspend fun rescheduleAlarms(context: Context) {
        val repository = SettingsRepository(context)
        val settings = repository.getSettings() ?: return

        val prayerTimes = PrayerTimesCalculator.calculateToday(settings)

        // Reschedule all alarms using the new permission state
        PrayerAlarmManager.rescheduleAll(context, prayerTimes)
        
        Log.i("ExactAlarmReceiver", "Alarms rescheduled after permission change")
    }
}

