package com.khwarizmi.fard.prayer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class NotificationDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val targetStr = intent.getStringExtra("targetStr") ?: return
        Log.d("NotificationDismissRec", "Explicitly hiding notification for target: $targetStr")
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        prefs.edit().putString("flutter.dismissed_prayer_target", targetStr).apply()
        CountdownNotificationManager.cancelNotification(context)
    }
}

