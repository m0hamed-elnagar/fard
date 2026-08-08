package com.khwarizmi.fard.prayer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import java.io.File
import java.io.RandomAccessFile
import org.json.JSONArray
import org.json.JSONObject

class MarkPrayedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val prayerId = intent.getStringExtra("prayerId") ?: return
        val dateStr = intent.getStringExtra("dateStr") ?: return
        Log.d("MarkPrayedReceiver", "Received mark prayed action for $prayerId on $dateStr")

        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // 1. Mark as persistently done for display
        val doneKey = "flutter.prayer_done_${prayerId}_$dateStr"
        prefs.edit().putBoolean(doneKey, true).apply()

        // 2. Append to pending_prayers.json under file lock
        val cacheFile = File(context.cacheDir, "pending_prayers.json")
        val lockFile = File(context.cacheDir, "pending_prayers.lock")
        
        synchronized(lockObject) {
            try {
                RandomAccessFile(lockFile, "rw").use { raf ->
                    raf.channel.lock().use {
                        val currentQueue = if (cacheFile.exists()) {
                            cacheFile.readText()
                        } else {
                            "[]"
                        }
                        val jsonArray = try {
                            JSONArray(currentQueue)
                        } catch (e: Exception) {
                            JSONArray()
                        }
                        
                        val newEntry = JSONObject().apply {
                            put("prayerId", prayerId)
                            put("date", dateStr)
                            put("timestamp", System.currentTimeMillis())
                        }
                        jsonArray.put(newEntry)
                        
                        cacheFile.writeText(jsonArray.toString())
                        Log.d("MarkPrayedReceiver", "Appended $prayerId to pending queue. New size: ${jsonArray.length()}")
                    }
                }
            } catch (e: Exception) {
                Log.e("MarkPrayedReceiver", "Error appending to pending queue file", e)
            }
        }

        // 3. Update the countdown notification immediately
        CountdownNotificationManager.updateCountdownNotification(context)
    }

    companion object {
        val lockObject = Any()
    }
}
