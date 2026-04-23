package com.qada.fard.widget

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.edit
import androidx.glance.appwidget.updateAll
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.batoulapps.adhan.PrayerTimes
import com.qada.fard.NextPrayerCountdownWidgetReceiver
import com.qada.fard.PrayerWidget
import com.qada.fard.prayer.PrayerTimesCalculator
import com.qada.fard.prayer.SettingsRepository
import org.json.JSONObject
import java.util.Calendar
import java.util.Locale

class WidgetUpdateWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        Log.d("WidgetUpdateWorker", "Safety net worker running - updating widgets with fresh data")

        return try {
            // Calculate fresh prayer times natively
            val repository = SettingsRepository(applicationContext)
            val settings = repository.getSettings()
            
            if (settings != null) {
                // Calculate today's prayer times
                val prayerTimes = PrayerTimesCalculator.calculateToday(settings)
                
                // Calculate tomorrow's Fajr for after-Isha scenario
                val tomorrowPrayerTimes = PrayerTimesCalculator.calculateTomorrow(settings)
                
                // Determine next prayer and time
                val now = Calendar.getInstance()
                val nextPrayerInfo = getNextPrayer(now, prayerTimes, tomorrowPrayerTimes)
                
                // Build widget data JSON (same format as Flutter's WidgetUpdateService)
                val widgetData = buildWidgetData(
                    repository = repository,
                    prayerTimes = prayerTimes,
                    nextPrayerName = nextPrayerInfo.name,
                    nextPrayerTime = nextPrayerInfo.time,
                    isRtl = settings.locale == "ar",
                    lastUpdated = System.currentTimeMillis()
                )
                
                // Save to SharedPreferences (this is what the widgets read from)
                val prefs = applicationContext.getSharedPreferences(
                    "FlutterSharedPreferences",
                    Context.MODE_PRIVATE
                )
                prefs.edit {
                    putString("flutter.prayer_data", widgetData)
                }
                
                Log.d("WidgetUpdateWorker", "Saved fresh prayer data to flutter.prayer_data")
            } else {
                Log.w("WidgetUpdateWorker", "No settings available - updating widgets with cached data only")
            }
            
            // Update the main PrayerWidget directly
            PrayerWidget().updateAll(applicationContext)

            // For the CountdownWidget, send a broadcast to the receiver
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
    
    private data class PrayerInfo(val name: String, val time: Long)
    
    private fun getNextPrayer(
        now: Calendar,
        todayTimes: PrayerTimes,
        tomorrowTimes: PrayerTimes
    ): PrayerInfo {
        val nowClear = now.clone() as Calendar
        nowClear.set(Calendar.SECOND, 0)
        nowClear.set(Calendar.MILLISECOND, 0)
        
        val prayers = listOf(
            Pair("Fajr", todayTimes.fajr),
            Pair("Dhuhr", todayTimes.dhuhr),
            Pair("Asr", todayTimes.asr),
            Pair("Maghrib", todayTimes.maghrib),
            Pair("Isha", todayTimes.isha)
        )
        
        for ((name, time) in prayers) {
            if (nowClear.timeInMillis < time.time) {
                return PrayerInfo(name, time.time)
            }
        }
        
        return PrayerInfo("Fajr", tomorrowTimes.fajr.time)
    }
    
    private fun buildWidgetData(
        repository: SettingsRepository,
        prayerTimes: PrayerTimes,
        nextPrayerName: String,
        nextPrayerTime: Long,
        isRtl: Boolean,
        lastUpdated: Long
    ): String {
        val now = Calendar.getInstance()
        val lang = if (isRtl) "ar" else "en"
        
        val existingJsonStr = repository.getPrayerDataJson()
        val existingJson = if (existingJsonStr != null) try { JSONObject(existingJsonStr) } catch(e: Exception) { null } else null

        val prayers = org.json.JSONArray()
        listOf(
            Pair("fajr", prayerTimes.fajr),
            Pair("dhuhr", prayerTimes.dhuhr),
            Pair("asr", prayerTimes.asr),
            Pair("maghrib", prayerTimes.maghrib),
            Pair("isha", prayerTimes.isha)
        ).forEach { (name, time) ->
            val prayerObj = JSONObject().apply {
                put("name", getPrayerNameLocalizedName(name, lang))
                put("time", formatTime(time.time, lang))
                put("minutesFromMidnight", getMinutesFromMidnight(time.time))
            }
            prayers.put(prayerObj)
        }
        
        return JSONObject().apply {
            put("gregorianDate", formatDate(now.time, lang))
            put("hijriDate", repository.getCachedHijriDate() ?: "Loading...")
            put("dayOfWeek", formatDayOfWeek(now, lang))
            put("sunrise", formatTime(prayerTimes.sunrise.time, lang))
            put("isRtl", isRtl)
            put("prayers", prayers)
            put("nextPrayerName", getPrayerNameLocalizedName(nextPrayerName, lang))
            put("nextPrayerTime", nextPrayerTime)
            put("lastUpdated", lastUpdated)

            if (existingJson != null) {
                val cu = ColorUtils
                listOf(
                    "primaryColorHex", "accentColorHex", "backgroundColorHex",
                    "surfaceColorHex", "textColorHex", "textSecondaryColorHex"
                ).forEach { key ->
                    if (existingJson.has(key)) {
                        val hex = existingJson.getString(key)
                        if (cu.isValidHex(hex)) {
                            put(key, hex)
                        }
                    }
                }
            }
        }.toString()
    }
    
    private fun getPrayerNameLocalizedName(id: String, lang: String): String {
        return if (lang == "ar") {
            when (id.lowercase()) {
                "fajr" -> "الفجر"
                "dhuhr" -> "الظهر"
                "asr" -> "العصر"
                "maghrib" -> "المغرب"
                "isha" -> "العشاء"
                else -> id
            }
        } else {
            when (id.lowercase()) {
                "fajr" -> "Fajr"
                "dhuhr" -> "Dhuhr"
                "asr" -> "Asr"
                "maghrib" -> "Maghrib"
                "isha" -> "Isha"
                else -> id
            }
        }
    }
    
    private fun formatTime(timeMs: Long, lang: String): String {
        val cal = Calendar.getInstance().apply { timeInMillis = timeMs }
        val hour = cal.get(Calendar.HOUR_OF_DAY)
        val minute = cal.get(Calendar.MINUTE)

        val period = if (hour < 12) "AM" else "PM"
        val h = if (hour == 0 || hour == 12) 12 else hour % 12
        return String.format(Locale.US, "%d:%02d %s", h, minute, period)
    }
    
    private fun getMinutesFromMidnight(timeMs: Long): Int {
        val cal = Calendar.getInstance().apply { timeInMillis = timeMs }
        return cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
    }
    
    private fun formatDate(date: java.util.Date, lang: String): String {
        val format = java.text.SimpleDateFormat("d MMMM yyyy", java.util.Locale(lang))
        return format.format(date)
    }
    
    private fun formatDayOfWeek(calendar: Calendar, lang: String): String {
        val format = java.text.SimpleDateFormat("EEEE", java.util.Locale(lang))
        return format.format(calendar.time)
    }
}
