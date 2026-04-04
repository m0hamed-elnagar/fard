package com.qada.fard

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.TextAlign
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.qada.fard.prayer.SettingsRepository
import org.json.JSONObject
import java.util.*

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

        val width = size.width
        val height = size.height
        
        val isTiny = width < 110.dp || height < 110.dp
        val isWide = width > 150.dp && height < 110.dp
        val isSmall = !isTiny && (width < 140.dp || height < 140.dp)
        val isLarge = width >= 200.dp && height >= 200.dp

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
                .clickable(actionStartActivity<MainActivity>())
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
            
            val timeText = if (hours > 0) "${hours}h ${minutes}m" else "${minutes}m"
            val statusText = when {
                totalMinutes > 0 -> timeText
                totalMinutes < 0 -> "+$timeText"
                else -> "Now"
            }

            if (isWide) {
                WideLayout(data, statusText, accentGold, textPrimary)
            } else if (isTiny) {
                TinyLayout(data, statusText, accentGold, textPrimary)
            } else {
                // Standard/Large Vertical layout
                val label = if (data.isRtl) "الصلاة القادمة" else "Next Prayer"
                if (!isSmall) {
                    Text(
                        text = label,
                        style = TextStyle(color = ColorProvider(textPrimary), fontSize = 12.sp)
                    )
                }
                
                val nameFontSize = if (isSmall) 16.sp else if (isLarge) 24.sp else 20.sp
                
                Text(
                    text = data.nextPrayerName,
                    style = TextStyle(
                        color = ColorProvider(accentGold), 
                        fontSize = nameFontSize, 
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center
                    )
                )
                
                Spacer(modifier = GlanceModifier.height(if (isSmall) 4.dp else 8.dp))
                
                val timeFontSize = if (isSmall) 20.sp else if (isLarge) 36.sp else 28.sp

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

    @Composable
    private fun TinyLayout(
        data: CountdownData, 
        statusText: String,
        accentGold: Color, 
        textPrimary: Color
    ) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = data.nextPrayerName,
                style = TextStyle(
                    color = ColorProvider(accentGold), 
                    fontSize = 12.sp, 
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
            )
            Spacer(modifier = GlanceModifier.height(4.dp))
            Box(
                modifier = GlanceModifier
                    .width(40.dp)
                    .height(1.dp)
                    .background(ColorProvider(accentGold))
            ) {}
            Spacer(modifier = GlanceModifier.height(4.dp))
            Text(
                text = statusText,
                style = TextStyle(
                    color = ColorProvider(textPrimary), 
                    fontSize = 16.sp, 
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
            )
        }
    }

    @Composable
    private fun WideLayout(
        data: CountdownData, 
        statusText: String,
        accentGold: Color, 
        textPrimary: Color
    ) {
        Row(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (data.isRtl) {
                Text(
                    text = statusText,
                    style = TextStyle(
                        color = ColorProvider(textPrimary), 
                        fontSize = 18.sp, 
                        fontWeight = FontWeight.Bold
                    )
                )
                Spacer(modifier = GlanceModifier.width(12.dp))
                Box(
                    modifier = GlanceModifier
                        .width(1.dp)
                        .height(20.dp)
                        .background(ColorProvider(accentGold))
                ) {}
                Spacer(modifier = GlanceModifier.width(12.dp))
                Text(
                    text = data.nextPrayerName,
                    style = TextStyle(
                        color = ColorProvider(accentGold), 
                        fontSize = 16.sp, 
                        fontWeight = FontWeight.Bold
                    )
                )
            } else {
                Text(
                    text = data.nextPrayerName,
                    style = TextStyle(
                        color = ColorProvider(accentGold), 
                        fontSize = 16.sp, 
                        fontWeight = FontWeight.Bold
                    )
                )
                Spacer(modifier = GlanceModifier.width(12.dp))
                Box(
                    modifier = GlanceModifier
                        .width(1.dp)
                        .height(20.dp)
                        .background(ColorProvider(accentGold))
                ) {}
                Spacer(modifier = GlanceModifier.width(12.dp))
                Text(
                    text = statusText,
                    style = TextStyle(
                        color = ColorProvider(textPrimary), 
                        fontSize = 18.sp, 
                        fontWeight = FontWeight.Bold
                    )
                )
            }
        }
    }
}