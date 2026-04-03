package com.qada.fard.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.core.content.edit
import androidx.glance.appwidget.updateAll
import com.qada.fard.PrayerWidget
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

/**
 * Helper object for synchronous widget updates.
 *
 * Use [saveAndUpdate] when you need to write data to SharedPreferences
 * and immediately update the widget, ensuring no race condition where
 * the widget reads stale data.
 */
object WidgetCommitHelper {

    /**
     * Writes data synchronously (.commit) then immediately updates the widget.
     * Use this instead of home_widget's saveWidgetData when an update must follow.
     *
     * @param context Android context
     * @param data Map of key-value pairs to save to SharedPreferences
     */
    fun saveAndUpdate(context: Context, data: Map<String, Any?>) {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", // Must match home_widget's prefs name
            Context.MODE_PRIVATE
        )

        // .commit = true blocks until write is complete — no race condition
        prefs.edit(commit = true) {
            data.forEach { (key, value) ->
                when (value) {
                    is String -> putString("flutter.$key", value)
                    is Int -> putInt("flutter.$key", value)
                    is Boolean -> putBoolean("flutter.$key", value)
                    is Float -> putFloat("flutter.$key", value)
                    is Long -> putLong("flutter.$key", value)
                    is Double -> putString("flutter.$key", value.toString())
                    null -> remove("flutter.$key")
                }
            }
        } // ← synchronous, guaranteed before next line

        // Now safe to update — data is definitely written
        triggerUpdate(context)
    }

    /**
     * Triggers an immediate widget update using Glance.
     *
     * @param context Android context
     */
    fun triggerUpdate(context: Context) {
        MainScope().launch {
            PrayerWidget().updateAll(context)
        }
    }
}
