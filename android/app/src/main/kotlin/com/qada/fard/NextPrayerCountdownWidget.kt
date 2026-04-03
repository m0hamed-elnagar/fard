package com.qada.fard

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.ActionCallback          // ✅ correct package
import androidx.glance.appwidget.action.actionRunCallback      // ✅ correct package
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.qada.fard.prayer.CalculationContract
import com.qada.fard.prayer.SettingsRepository
import org.json.JSONObject
import java.util.*
import java.util.concurrent.TimeUnit

class NextPrayerCountdownWidget : GlanceAppWidget() {

    override val sizeMode: SizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val repository = SettingsRepository(context)
        val prayerDataJson = repository.getPrayerDataJson()
        
        val widgetData = try {
            if (prayerDataJson != null) parseWidgetData(prayerDataJson) else null
        } catch (e: Exception) {
            null
        }

        provideContent {
            val size = LocalSize.current
            CountdownWidgetRoot(widgetData)
        }
    }

    private fun parseWidgetData(jsonString: String): CountdownData {
        val json = JSONObject(jsonString)
        return CountdownData(
            nextPrayerName = json.optString("nextPrayerName", ""),
            nextPrayerTime = json.optLong("nextPrayerTime", 0L),
            isRtl = json.getBoolean("isRtl"),
            lastUpdated = json.getLong("lastUpdated")
        )
    }

    data class CountdownData(
        val nextPrayerName: String,
        val nextPrayerTime: Long,
        val isRtl: Boolean,
        val lastUpdated: Long
    )

    @Composable
    private fun CountdownWidgetRoot(data: CountdownData?) {
        val accentGold = Color(0xFFFFD54F)
        val textPrimary = Color(0xFFF0F6FC)

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ImageProvider(R.drawable.widget_background))
                .clickable(actionRunCallback<SafeOpenAppCallback>())
                .padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Check for stale data (> 24h) or missing data
            if (data == null || data.nextPrayerTime == 0L || (System.currentTimeMillis() - data.lastUpdated > 24 * 60 * 60 * 1000)) {
                Text(
                    text = "Open App",
                    style = TextStyle(color = ColorProvider(textPrimary))
                )
                return@Column
            }

            val diff = data.nextPrayerTime - System.currentTimeMillis()

            if (diff > 0) {
                // Precise minute calculation: Strip seconds and millis to match system clock exactly
                val prayerCal = Calendar.getInstance().apply { timeInMillis = data.nextPrayerTime }
                val nowCal = Calendar.getInstance()
                
                // Clear seconds and milliseconds for boundary-perfect precision
                prayerCal.set(Calendar.SECOND, 0)
                prayerCal.set(Calendar.MILLISECOND, 0)
                nowCal.set(Calendar.SECOND, 0)
                nowCal.set(Calendar.MILLISECOND, 0)

                val totalMinutes = (prayerCal.timeInMillis - nowCal.timeInMillis) / 60000
                
                // Handle edge case where stripped diff might be 0 if we are in the last minute
                val displayMinutes = if (totalMinutes <= 0) 1L else totalMinutes
                
                val hours = displayMinutes / 60
                val minutes = displayMinutes % 60
                
                val countdownText = when {
                    hours > 0 -> "${hours}h ${minutes}m"
                    else -> "${minutes}m"
                }

                Text(
                    text = if (data.isRtl) "الصلاة القادمة" else "Next Prayer",
                    style = TextStyle(color = ColorProvider(textPrimary), fontSize = 14.sp)
                )
                
                Text(
                    text = data.nextPrayerName,
                    style = TextStyle(
                        color = ColorProvider(accentGold), 
                        fontSize = 20.sp, 
                        fontWeight = FontWeight.Bold
                    )
                )
                
                Spacer(modifier = GlanceModifier.height(8.dp))
                
                Text(
                    text = countdownText,
                    style = TextStyle(
                        color = ColorProvider(textPrimary), 
                        fontSize = 24.sp, 
                        fontWeight = FontWeight.Bold
                    )
                )
            } else {
                // If diff <= 0, it means the prayer time has passed but the widget hasn't 
                // received the next sync yet. Show the prayer name with a "Now" or "Soon" label.
                Text(
                    text = data.nextPrayerName,
                    style = TextStyle(
                        color = ColorProvider(accentGold), 
                        fontSize = 20.sp, 
                        fontWeight = FontWeight.Bold
                    )
                )
                Text(
                    text = "Now",
                    style = TextStyle(color = ColorProvider(textPrimary), fontSize = 24.sp)
                )
            }
        }
    }
}

// Top-level class required — actionRunCallback<T>() cannot resolve inner/nested classes
class SafeOpenAppCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        try {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            android.util.Log.e("SafeOpenAppCallback", "Failed to start activity", e)
        }
    }
}