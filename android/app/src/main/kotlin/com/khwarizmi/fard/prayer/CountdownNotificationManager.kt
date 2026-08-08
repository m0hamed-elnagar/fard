package com.khwarizmi.fard.prayer

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import android.widget.RemoteViews
import com.khwarizmi.fard.R
import com.khwarizmi.fard.MainActivity
import org.json.JSONArray
import java.util.Calendar
import java.util.Locale
import java.text.SimpleDateFormat
import java.util.Date

import android.os.SystemClock

object CountdownNotificationManager {
    private const val CHANNEL_ID = "salah_countdown_v3"
    const val NOTIFICATION_ID = 900

    fun updateCountdownNotification(context: Context) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isEnabled = prefs.getBoolean("flutter.show_salah_countdown_notification", true)
        
        if (!isEnabled) {
            cancelNotification(context)
            return
        }

        val locale = prefs.getString("flutter.locale", "ar") ?: "ar"
        val isAr = locale == "ar"

        // 1. Read primary next prayer target keys from SharedPreferences
        var nextPrayerId = prefs.getString("flutter.next_prayer_id", "") ?: ""
        var nextPrayerTime = prefs.getLong("flutter.next_prayer_time", 0L)
        var nextPrayerDate = prefs.getString("flutter.next_prayer_date", "") ?: ""

        val now = System.currentTimeMillis()

        // 2. Perform native rollover check if current target has passed
        if (nextPrayerTime == 0L || now >= nextPrayerTime) {
            Log.d("CountdownNotification", "Target has passed or uninitialized, performing native rollover")
            val scheduleJson = prefs.getString("flutter.fard.adhan_schedule", null)
                ?: prefs.getString("fard.adhan_schedule", null)

            var rolledOver = false
            if (scheduleJson != null) {
                try {
                    val jsonArray = JSONArray(scheduleJson)
                    for (i in 0 until jsonArray.length()) {
                        val item = jsonArray.getJSONObject(i)
                        val timeEpochMs = item.optLong("timeEpochMs", 0L)
                        if (timeEpochMs > now) {
                            val prayerName = item.optString("prayerName", "")
                            
                            // Capture the exact epoch time of the prayer that just passed (index i - 1)
                            val prevItemTime = if (i > 0) {
                                jsonArray.getJSONObject(i - 1).optLong("timeEpochMs", 0L)
                            } else {
                                0L
                            }

                            nextPrayerId = getPrayerId(prayerName)
                            nextPrayerTime = timeEpochMs
                            
                            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.US)
                            nextPrayerDate = sdf.format(Date(timeEpochMs))

                            // Persist resolved rollover and updated prev_prayer_time back to SharedPreferences
                            prefs.edit().apply {
                                putString("flutter.next_prayer_id", nextPrayerId)
                                putLong("flutter.next_prayer_time", nextPrayerTime)
                                putString("flutter.next_prayer_date", nextPrayerDate)
                                if (prevItemTime > 0L) {
                                    putLong("flutter.prev_prayer_time", prevItemTime)
                                    putLong("prev_prayer_time", prevItemTime)
                                }
                            }.apply()

                            rolledOver = true
                            Log.d("CountdownNotification", "Native rollover succeeded to $nextPrayerId at $nextPrayerDate ($nextPrayerTime), prev prayer time: $prevItemTime")
                            break
                        }
                    }
                } catch (e: Exception) {
                    Log.e("CountdownNotification", "Error parsing adhan schedule for rollover", e)
                }
            }

            if (!rolledOver) {
                // Lookahead exhaustion fallback (schedule is empty or fully expired)
                Log.w("CountdownNotification", "Lookahead schedule exhausted, showing fallback instructions")
                showFallbackNotification(context, isAr)
                return
            }
        }

        // 3. Dismiss checking (dismiss target formatted as "id_date")
        val currentTargetStr = "${nextPrayerId}_$nextPrayerDate"
        val dismissedTarget = prefs.getString("flutter.dismissed_prayer_target", "") ?: ""

        if (dismissedTarget == currentTargetStr) {
            Log.d("CountdownNotification", "Notification dismissed for target $currentTargetStr, skipping update")
            return
        } else if (dismissedTarget.isNotEmpty()) {
            // Target rolled over, clear stale dismiss flag
            prefs.edit().putString("flutter.dismissed_prayer_target", "").apply()
        }

        // 4. Check if the previous prayer is marked completed
        val prevId = getPreviousPrayer(nextPrayerId)
        val prevDate = getPreviousPrayerDate(nextPrayerId, nextPrayerDate)
        
        val doneKey = "flutter.prayer_done_${prevId}_$prevDate"
        val isAlreadyDone = prefs.getBoolean(doneKey, false)

        val nextPrayerLocalizedName = getPrayerNameLocalized(nextPrayerId, if (isAr) "ar" else "en")
        val prevPrayerLocalizedName = getPrayerNameLocalized(prevId, if (isAr) "ar" else "en")

        val prayerTitleText = if (isAr) {
            "صلاة $nextPrayerLocalizedName"
        } else {
            "$nextPrayerLocalizedName Prayer"
        }

        // Read city name from SharedPreferences & translate to Arabic if locale is Arabic
        val rawCityName = prefs.getString("flutter.city_name", null)
            ?: prefs.getString("city_name", null)
        val localizedCityName = if (!rawCityName.isNullOrBlank()) getLocalizedCityName(rawCityName, isAr) else ""
        val locationText = if (localizedCityName.isNotEmpty()) "📍 $localizedCityName" else ""
        val hasLocation = locationText.isNotEmpty()

        val timeSdf = SimpleDateFormat("h:mm a", Locale(if (isAr) "ar" else "en"))
        val formattedPrayerTime = try {
            timeSdf.format(Date(nextPrayerTime))
        } catch (e: Exception) {
            ""
        }

        // Compute Chronometer base using SystemClock.elapsedRealtime()
        val currentElapsedMs = SystemClock.elapsedRealtime()
        val currentTimeMs = System.currentTimeMillis()
        val targetElapsedRealtime = currentElapsedMs + (nextPrayerTime - currentTimeMs)

        // Read storedPrevTime safely supporting both Long and Int types
        val storedPrevTime = try {
            val longVal = prefs.getLong("flutter.prev_prayer_time", 0L)
            if (longVal != 0L) longVal else prefs.getLong("prev_prayer_time", 0L)
        } catch (e: Exception) {
            try {
                val intVal = prefs.getInt("flutter.prev_prayer_time", 0)
                if (intVal != 0) intVal.toLong() else prefs.getInt("prev_prayer_time", 0).toLong()
            } catch (e2: Exception) {
                0L
            }
        }

        val isFajr = nextPrayerId.equals("fajr", ignoreCase = true)
        val maxAllowedIntervalMs = 14 * 3600 * 1000L

        val prevPrayerTime = if (storedPrevTime > 0L && storedPrevTime < nextPrayerTime && (nextPrayerTime - storedPrevTime) <= maxAllowedIntervalMs) {
            storedPrevTime
        } else {
            Log.w("CountdownNotification", "Stored prev_prayer_time ($storedPrevTime) invalid for next $nextPrayerId ($nextPrayerTime), using fallback interval estimate")
            nextPrayerTime - (if (isFajr) 8 * 3600 * 1000L else 4 * 3600 * 1000L)
        }

        val formattedPrevPrayerTime = try {
            timeSdf.format(Date(prevPrayerTime))
        } catch (e: Exception) {
            ""
        }

        val totalWindow = (nextPrayerTime - prevPrayerTime).coerceAtLeast(1L)
        val elapsed = (currentTimeMs - prevPrayerTime).coerceIn(0L, totalWindow)
        val progressPercent = ((elapsed.toDouble() / totalWindow.toDouble()) * 100).toInt().coerceIn(0, 100)

        val collapsedTimeText = if (formattedPrayerTime.isNotEmpty()) {
            if (isAr) "الموعد: $formattedPrayerTime" else "Time: $formattedPrayerTime"
        } else {
            ""
        }

        val countdownLabelText = if (isAr) {
            "الوقت المتبقي لصلاة $nextPrayerLocalizedName"
        } else {
            "Time remaining until $nextPrayerLocalizedName"
        }

        // Previous prayer label WITH start time restored
        val prevPrayerTimelineLabel = if (formattedPrevPrayerTime.isNotEmpty()) {
            "$prevPrayerLocalizedName ($formattedPrevPrayerTime)"
        } else {
            prevPrayerLocalizedName
        }

        // Next prayer label WITH target time
        val nextPrayerTimelineLabel = if (formattedPrayerTime.isNotEmpty()) {
            "$nextPrayerLocalizedName ($formattedPrayerTime)"
        } else {
            nextPrayerLocalizedName
        }

        val previousStatusText = if (isAlreadyDone) {
            if (isAr) {
                "✅ تم تسجيل صلاة $prevPrayerLocalizedName"
            } else {
                "✅ $prevPrayerLocalizedName logged successfully"
            }
        } else {
            if (isAr) {
                "⏳ صلاة $prevPrayerLocalizedName لم تؤدَ بعد"
            } else {
                "⏳ Pending: $prevPrayerLocalizedName"
            }
        }

        // Inflate custom RemoteViews layouts for collapsed and expanded views
        val collapsedViews = RemoteViews(context.packageName, R.layout.notification_countdown_collapsed).apply {
            setTextViewText(R.id.tv_prayer_title, prayerTitleText)
            setTextViewText(R.id.tv_prayer_time, collapsedTimeText)
            setProgressBar(R.id.pb_prayer_progress, 100, progressPercent, false)
            setViewVisibility(R.id.chronometer_countdown, android.view.View.VISIBLE)
            setChronometer(R.id.chronometer_countdown, targetElapsedRealtime, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                setChronometerCountDown(R.id.chronometer_countdown, true)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                setInt(R.id.notification_root_collapsed, "setLayoutDirection", if (isAr) android.view.View.LAYOUT_DIRECTION_RTL else android.view.View.LAYOUT_DIRECTION_LTR)
            }
        }

        val expandedViews = RemoteViews(context.packageName, R.layout.notification_countdown_expanded).apply {
            setTextViewText(R.id.tv_prayer_title_expanded, prayerTitleText)
            if (hasLocation) {
                setTextViewText(R.id.tv_location_expanded, locationText)
                setViewVisibility(R.id.tv_location_expanded, android.view.View.VISIBLE)
            } else {
                setViewVisibility(R.id.tv_location_expanded, android.view.View.GONE)
            }
            setTextViewText(R.id.tv_countdown_label, countdownLabelText)
            setViewVisibility(R.id.chronometer_countdown_expanded, android.view.View.VISIBLE)
            setChronometer(R.id.chronometer_countdown_expanded, targetElapsedRealtime, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                setChronometerCountDown(R.id.chronometer_countdown_expanded, true)
            }
            setProgressBar(R.id.pb_prayer_progress_expanded, 100, progressPercent, false)
            setTextViewText(R.id.tv_prev_prayer_label, prevPrayerTimelineLabel)
            setTextViewText(R.id.tv_next_prayer_label, nextPrayerTimelineLabel)
            setTextViewText(R.id.tv_previous_status, previousStatusText)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                setInt(R.id.notification_root, "setLayoutDirection", if (isAr) android.view.View.LAYOUT_DIRECTION_RTL else android.view.View.LAYOUT_DIRECTION_LTR)
            }
        }

        // Ensure channel exists
        createNotificationChannel(context)

        // PendingIntent for clicking notification (brings app to foreground)
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val launcherIconId = context.resources.getIdentifier("ic_launcher", "mipmap", context.packageName)
        val iconRes = if (launcherIconId != 0) launcherIconId else android.R.drawable.ic_dialog_info

        val publicContentText = if (hasLocation) {
            "$locationText • $collapsedTimeText"
        } else {
            collapsedTimeText
        }

        // Build Public Fallback Notification for AOSP lockscreen keyguard redacted privacy mode
        val publicBuilder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(iconRes)
            .setContentTitle(prayerTitleText)
            .setContentText(publicContentText)
            .setSubText(if (isAr) "فرض" else "Fard")
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
            .setWhen(nextPrayerTime)
            .setShowWhen(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(iconRes)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(collapsedViews)
            .setCustomBigContentView(expandedViews)
            .setSubText(if (isAr) "فرض" else "Fard")
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
            .setPublicVersion(publicBuilder.build())

        // PendingIntent for explicit "Hide" / "إخفاء" action
        val hideActionText = if (isAr) "إخفاء" else "Hide"
        val hideIntent = Intent(context, NotificationDismissReceiver::class.java).apply {
            putExtra("targetStr", currentTargetStr)
        }
        val hidePendingIntent = PendingIntent.getBroadcast(
            context,
            901,
            hideIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )
        val hideAction = NotificationCompat.Action.Builder(
            0,
            hideActionText,
            hidePendingIntent
        ).build()

        // Setup Actions
        if (isAlreadyDone) {
            builder.addAction(hideAction)
        } else {
            val actionText = if (isAr) {
                "✅ صليت $prevPrayerLocalizedName"
            } else {
                "✅ Prayed $prevPrayerLocalizedName"
            }

            val actionIntent = Intent(context, MarkPrayedReceiver::class.java).apply {
                putExtra("prayerId", prevId)
                putExtra("dateStr", prevDate)
            }
            val actionPendingIntent = PendingIntent.getBroadcast(
                context,
                902,
                actionIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )

            builder.addAction(
                NotificationCompat.Action.Builder(
                    0,
                    actionText,
                    actionPendingIntent
                ).build()
            )
            builder.addAction(hideAction)
        }

        val notification = builder.build().apply {
            flags = flags or NotificationCompat.FLAG_ONGOING_EVENT or android.app.Notification.FLAG_NO_CLEAR
        }

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        try {
            manager.notify(NOTIFICATION_ID, notification)
        } catch (e: Exception) {
            Log.e("CountdownNotification", "Error posting countdown notification", e)
        }
    }

    private fun getLocalizedCityName(city: String, isAr: Boolean): String {
        if (city.isBlank()) return ""
        val trimmed = city.trim()
        val lower = trimmed.lowercase(Locale.US)

        if (isAr) {
            return when {
                lower.contains("cairo") || lower.contains("qahir") -> "القاهرة"
                lower.contains("giza") || lower.contains("gizah") -> "الجيزة"
                lower.contains("alexandria") || lower.contains("iskandari") -> "الإسكندرية"
                lower.contains("mecca") || lower.contains("makkah") -> "مكة المكرمة"
                lower.contains("medina") || lower.contains("madinah") -> "المدينة المنورة"
                lower.contains("riyadh") || lower.contains("riyad") -> "الرياض"
                lower.contains("jeddah") || lower.contains("jiddah") -> "جدة"
                lower.contains("dammam") -> "الدمام"
                lower.contains("dubai") -> "دبي"
                lower.contains("abu dhabi") -> "أبوظبي"
                lower.contains("sharjah") -> "الشارقة"
                lower.contains("doha") -> "الدوحة"
                lower.contains("kuwait") -> "الكويت"
                lower.contains("manama") -> "المنامة"
                lower.contains("muscat") -> "مسقط"
                lower.contains("amman") -> "عمان"
                lower.contains("beirut") -> "بيروت"
                lower.contains("damascus") -> "دمشق"
                lower.contains("baghdad") -> "بغداد"
                lower.contains("jerusalem") || lower.contains("quds") -> "القدس"
                lower.contains("tripoli") -> "طرابلس"
                lower.contains("tunis") -> "تونس"
                lower.contains("algiers") -> "الجزائر"
                lower.contains("rabat") -> "الرباط"
                lower.contains("khartoum") -> "الخرطوم"
                lower.contains("istanbul") -> "إسطنبول"
                lower.contains("london") -> "لندن"
                lower.contains("paris") -> "باريس"
                lower.contains("new york") -> "نيويورك"
                else -> trimmed
            }
        } else {
            return when {
                trimmed.contains("القاهرة") -> "Cairo"
                trimmed.contains("الجيزة") -> "Giza"
                trimmed.contains("الإسكندرية") -> "Alexandria"
                trimmed.contains("مكة") -> "Mecca"
                trimmed.contains("المدينة") -> "Medina"
                trimmed.contains("الرياض") -> "Riyadh"
                trimmed.contains("جدة") -> "Jeddah"
                trimmed.contains("الدمام") -> "Dammam"
                trimmed.contains("دبي") -> "Dubai"
                trimmed.contains("أبوظبي") || trimmed.contains("ابوظبي") -> "Abu Dhabi"
                trimmed.contains("الشارقة") -> "Sharjah"
                trimmed.contains("الدوحة") -> "Doha"
                trimmed.contains("الكويت") -> "Kuwait"
                trimmed.contains("المنامة") -> "Manama"
                trimmed.contains("مسقط") -> "Muscat"
                trimmed.contains("عمان") -> "Amman"
                trimmed.contains("بيروت") -> "Beirut"
                trimmed.contains("دمشق") -> "Damascus"
                trimmed.contains("بغداد") -> "Baghdad"
                trimmed.contains("القدس") -> "Jerusalem"
                trimmed.contains("طرابلس") -> "Tripoli"
                trimmed.contains("تونس") -> "Tunis"
                trimmed.contains("الجزائر") -> "Algiers"
                trimmed.contains("الرباط") -> "Rabat"
                trimmed.contains("الخرطوم") -> "Khartoum"
                trimmed.contains("إسطنبول") || trimmed.contains("اسطنبول") -> "Istanbul"
                else -> trimmed
            }
        }
    }

    private fun showFallbackNotification(context: Context, isAr: Boolean) {
        createNotificationChannel(context)
        val title = if (isAr) {
            "مواقيت الصلاة منتهية"
        } else {
            "Prayer times expired"
        }
        val desc = if (isAr) {
            "افتح التطبيق لتحديث مواقيت الصلاة"
        } else {
            "Open Fard to update prayer times"
        }

        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val launcherIconId = context.resources.getIdentifier("ic_launcher", "mipmap", context.packageName)
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(if (launcherIconId != 0) launcherIconId else android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(desc)
            .setUsesChronometer(false)
            .setShowWhen(false)
            .setOngoing(false)
            .setContentIntent(contentIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        try {
            manager.notify(NOTIFICATION_ID, builder.build())
        } catch (e: Exception) {
            Log.e("CountdownNotification", "Error posting fallback notification", e)
        }
    }

    fun cancelNotification(context: Context) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NOTIFICATION_ID)
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val isAr = prefs.getString("flutter.locale", "ar") == "ar"
            
            val name = if (isAr) "مؤقت الصلاة التالية" else "Salah Countdown"
            val desc = if (isAr) "عرض العد التنازلي للصلاة التالية بشكل مستمر" else "Persistent countdown to the next Salah"
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Delete legacy channels to prevent ghost entries in System Settings
            try {
                manager.deleteNotificationChannel("salah_countdown_channel")
                manager.deleteNotificationChannel("salah_countdown_channel_v2")
            } catch (e: Exception) {
                // Ignore if legacy channels do not exist
            }

            val channel = NotificationChannel(CHANNEL_ID, name, NotificationManager.IMPORTANCE_DEFAULT).apply {
                description = desc
                setShowBadge(false)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            manager.createNotificationChannel(channel)
        }
    }

    private fun getPrayerId(name: String): String {
        return when (name.lowercase(Locale.US)) {
            "fajr", "الفجر" -> "fajr"
            "dhuhr", "الظهر" -> "dhuhr"
            "asr", "العصر" -> "asr"
            "maghrib", "المغرب" -> "maghrib"
            "isha", "العشاء" -> "isha"
            else -> name.lowercase(Locale.US)
        }
    }

    private fun getPrayerNameLocalized(name: String, lang: String): String {
        return if (lang == "ar") {
            when (name.lowercase(Locale.US)) {
                "fajr" -> "الفجر"
                "dhuhr" -> "الظهر"
                "asr" -> "العصر"
                "maghrib" -> "المغرب"
                "isha" -> "العشاء"
                else -> name
            }
        } else {
            when (name.lowercase(Locale.US)) {
                "fajr" -> "Fajr"
                "dhuhr" -> "Dhuhr"
                "asr" -> "Asr"
                "maghrib" -> "Maghrib"
                "isha" -> "Isha"
                else -> name
            }
        }
    }

    private fun getPreviousPrayer(current: String): String {
        return when (current.lowercase(Locale.US)) {
            "fajr" -> "isha"
            "dhuhr" -> "fajr"
            "asr" -> "dhuhr"
            "maghrib" -> "asr"
            "isha" -> "maghrib"
            else -> current
        }
    }

    private fun getPreviousPrayerDate(current: String, currentDateStr: String): String {
        if (current.lowercase(Locale.US) != "fajr") {
            return currentDateStr
        }
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        try {
            val date = sdf.parse(currentDateStr) ?: return currentDateStr
            val cal = Calendar.getInstance().apply { time = date }
            cal.add(Calendar.DAY_OF_YEAR, -1)
            return sdf.format(cal.time)
        } catch (e: Exception) {
            return currentDateStr
        }
    }
}
