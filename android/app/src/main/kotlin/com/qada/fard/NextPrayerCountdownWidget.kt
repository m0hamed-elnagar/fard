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
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.TextAlign
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
            CountdownWidgetRoot(widgetData, size)
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
    private fun CountdownWidgetRoot(data: CountdownData?, size: DpSize) {
        val accentGold = Color(0xFFFFD54F)
        val textPrimary = Color(0xFFF0F6FC)

        // Granular size detection for responsiveness
        val width = size.width
        val height = size.height
        
        val isTiny = width < 80.dp || height < 80.dp
        val isSmall = !isTiny && (width < 120.dp || height < 120.dp)
        val isWide = width > height * 1.5f && width > 150.dp
        val isLarge = width >= 180.dp && height >= 180.dp

        val padding = when {
            isTiny -> 6.dp
            isSmall -> 12.dp
            isLarge -> 24.dp
            else -> 18.dp
        }

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ImageProvider(R.drawable.widget_background))
                .clickable(actionRunCallback<SafeOpenAppCallback>())
                .padding(padding),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Check for stale data (> 24h) or missing data
            if (data == null || data.nextPrayerTime == 0L || (System.currentTimeMillis() - data.lastUpdated > 24 * 60 * 60 * 1000)) {
                Text(
                    text = "Open App",
                    style = TextStyle(
                        color = ColorProvider(textPrimary), 
                        fontSize = if (isTiny) 10.sp else 14.sp,
                        textAlign = TextAlign.Center
                    )
                )
                return@Column
            }

            val diff = data.nextPrayerTime - System.currentTimeMillis()
            val isRtl = data.isRtl

            // Calculate display time
            val prayerCal = Calendar.getInstance().apply { timeInMillis = data.nextPrayerTime }
            val nowCal = Calendar.getInstance()
            
            prayerCal.set(Calendar.SECOND, 0)
            prayerCal.set(Calendar.MILLISECOND, 0)
            nowCal.set(Calendar.SECOND, 0)
            nowCal.set(Calendar.MILLISECOND, 0)

            val totalMinutes = (prayerCal.timeInMillis - nowCal.timeInMillis) / 60000
            val absMinutes = Math.abs(totalMinutes)
            val hours = absMinutes / 60
            val minutes = absMinutes % 60
            
            val timeText = when {
                hours > 0 -> "${hours}h ${minutes}m"
                else -> "${minutes}m"
            }
            
            val statusText = when {
                totalMinutes > 0 -> timeText
                totalMinutes < 0 -> "+$timeText"
                else -> "Now"
            }

            // UI Layout starts here
            if (isWide) {
                // Horizontal layout for wide widgets
                Row(
                    modifier = GlanceModifier.fillMaxSize(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Column(modifier = GlanceModifier.defaultWeight()) {
                        Text(
                            text = if (isRtl) "الصلاة القادمة" else "Next Prayer",
                            style = TextStyle(color = ColorProvider(textPrimary), fontSize = 11.sp)
                        )
                        Text(
                            text = data.nextPrayerName,
                            style = TextStyle(
                                color = ColorProvider(accentGold), 
                                fontSize = 18.sp, 
                                fontWeight = FontWeight.Bold
                            )
                        )
                    }
                    Text(
                        text = statusText,
                        style = TextStyle(
                            color = ColorProvider(textPrimary), 
                            fontSize = 24.sp, 
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.End
                        )
                    )
                }
            } else {
                // Vertical layout for standard/small widgets
                if (isTiny) {
                    // Distinct look for 1x1: High contrast between name and time
                    Text(
                        text = data.nextPrayerName,
                        style = TextStyle(
                            color = ColorProvider(accentGold), 
                            fontSize = 11.sp, 
                            fontWeight = FontWeight.Normal,
                            textAlign = TextAlign.Center
                        )
                    )
                    Text(
                        text = statusText,
                        style = TextStyle(
                            color = ColorProvider(textPrimary), 
                            fontSize = 18.sp, 
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                    )
                } else {
                    // Standard vertical layout
                    if (!isSmall) {
                        Text(
                            text = if (isRtl) "الصلاة القادمة" else "Next Prayer",
                            style = TextStyle(color = ColorProvider(textPrimary), fontSize = 12.sp)
                        )
                    }
                    
                    val nameFontSize = if (isSmall) 15.sp else if (isLarge) 22.sp else 18.sp
                    
                    Text(
                        text = data.nextPrayerName,
                        style = TextStyle(
                            color = ColorProvider(accentGold), 
                            fontSize = nameFontSize, 
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                    )
                    
                    Spacer(modifier = GlanceModifier.height(if (isSmall) 2.dp else 4.dp))
                    
                    val timeFontSize = if (isSmall) 18.sp else if (isLarge) 32.sp else 24.sp

                    Text(
                        text = statusText,
                        style = TextStyle(
                            color = ColorProvider(textPrimary), 
                            fontSize = timeFontSize, 
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                    )
                }
            }
        }
    }
}

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