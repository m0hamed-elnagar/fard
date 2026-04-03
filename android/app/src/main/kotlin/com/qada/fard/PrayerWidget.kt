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
import androidx.glance.appwidget.cornerRadius
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

class PrayerWidget : GlanceAppWidget() {

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
            PrayerWidgetRoot(widgetData, size)
        }
    }

    private fun parseWidgetData(jsonString: String): WidgetData {
        val json = JSONObject(jsonString)
        val prayersArray = json.getJSONArray("prayers")
        val prayers = mutableListOf<PrayerItem>()
        for (i in 0 until prayersArray.length()) {
            val item = prayersArray.getJSONObject(i)
            prayers.add(
                PrayerItem(
                    name = item.getString("name"),
                    time = item.getString("time")
                )
            )
        }

        return WidgetData(
            gregorianDate = json.getString("gregorianDate"),
            hijriDate = json.getString("hijriDate"),
            dayOfWeek = json.getString("dayOfWeek"),
            sunrise = json.getString("sunrise"),
            isRtl = json.getBoolean("isRtl"),
            nextPrayerName = json.optString("nextPrayerName", ""),
            prayers = prayers,
            lastUpdated = json.getLong("lastUpdated")
        )
    }

    data class WidgetData(
        val gregorianDate: String,
        val hijriDate: String,
        val dayOfWeek: String,
        val sunrise: String,
        val isRtl: Boolean,
        val nextPrayerName: String,
        val prayers: List<PrayerItem>,
        val lastUpdated: Long
    )

    data class PrayerItem(
        val name: String,
        val time: String
    )

    @Composable
    private fun PrayerWidgetRoot(data: WidgetData?, size: DpSize) {
        val primaryGreen = Color(0xFF2E7D32)
        val accentGold = Color(0xFFFFD54F)
        val textPrimary = Color(0xFFF0F6FC)
        val textSecondary = Color(0xFF8B949E)

        val isTiny = size.width < 110.dp || size.height < 110.dp
        val isCompact = size.height < 220.dp

        val hPad = if (isCompact) 6.dp else 16.dp
        val vPad = if (isCompact) 4.dp else 14.dp

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ImageProvider(R.drawable.widget_background))
                .clickable(actionStartActivity<MainActivity>())
                .padding(horizontal = hPad, vertical = vPad),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Check for stale data (> 24h)
            if (data == null || (System.currentTimeMillis() - data.lastUpdated > 24 * 60 * 60 * 1000)) {
                Box(modifier = GlanceModifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("Open App", style = TextStyle(color = ColorProvider(textPrimary)))
                }
                return@Column
            }

            if (isTiny) {
                TinyLayout(data, size, accentGold, textPrimary)
            } else {
                FullLayout(
                    data,
                    size,
                    isCompact,
                    primaryGreen,
                    accentGold,
                    textPrimary,
                    textSecondary
                )
            }
        }
    }

    @Composable
    private fun TinyLayout(
        data: WidgetData, size: DpSize,
        accentGold: Color, textPrimary: Color
    ) {
        val next = data.prayers.find { it.name == data.nextPrayerName } ?: data.prayers.first()
        val isRtl = data.isRtl

        if (size.width > 150.dp) {
            Row(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                if (isRtl) {
                    Text(text = next.time, style = TextStyle(color = ColorProvider(textPrimary), fontSize = 18.sp, fontWeight = FontWeight.Bold))
                    Spacer(modifier = GlanceModifier.width(8.dp))
                    Box(modifier = GlanceModifier.width(1.dp).height(16.dp).background(ColorProvider(accentGold))) {}
                    Spacer(modifier = GlanceModifier.width(8.dp))
                    Text(text = next.name, style = TextStyle(color = ColorProvider(accentGold), fontSize = 16.sp, fontWeight = FontWeight.Bold))
                } else {
                    Text(text = next.name, style = TextStyle(color = ColorProvider(accentGold), fontSize = 16.sp, fontWeight = FontWeight.Bold))
                    Spacer(modifier = GlanceModifier.width(8.dp))
                    Box(modifier = GlanceModifier.width(1.dp).height(16.dp).background(ColorProvider(accentGold))) {}
                    Spacer(modifier = GlanceModifier.width(8.dp))
                    Text(text = next.time, style = TextStyle(color = ColorProvider(textPrimary), fontSize = 18.sp, fontWeight = FontWeight.Bold))
                }
            }
        } else {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                if (isRtl) {
                    Text(text = next.time, style = TextStyle(color = ColorProvider(textPrimary), fontSize = 16.sp, fontWeight = FontWeight.Bold))
                    Spacer(modifier = GlanceModifier.height(3.dp))
                    Box(modifier = GlanceModifier.width(36.dp).height(1.dp).background(ColorProvider(accentGold))) {}
                    Spacer(modifier = GlanceModifier.height(3.dp))
                    Text(text = next.name, style = TextStyle(color = ColorProvider(accentGold), fontSize = 12.sp, fontWeight = FontWeight.Bold))
                } else {
                    Text(text = next.name, style = TextStyle(color = ColorProvider(accentGold), fontSize = 12.sp, fontWeight = FontWeight.Bold))
                    Spacer(modifier = GlanceModifier.height(3.dp))
                    Box(modifier = GlanceModifier.width(36.dp).height(1.dp).background(ColorProvider(accentGold))) {}
                    Spacer(modifier = GlanceModifier.height(3.dp))
                    Text(text = next.time, style = TextStyle(color = ColorProvider(textPrimary), fontSize = 16.sp, fontWeight = FontWeight.Bold))
                }
            }
        }
    }

    @Composable
    private fun ColumnScope.FullLayout(
        data: WidgetData,
        size: DpSize,
        isCompact: Boolean,
        primaryGreen: Color,
        accentGold: Color,
        textPrimary: Color,
        textSecondary: Color
    ) {
        val headerFontSize = when {
            size.height < 160.dp -> 9.sp
            size.height < 220.dp -> 11.sp
            size.height < 320.dp -> 13.sp
            else -> 15.sp
        }
        val rowFontSize = when {
            size.height < 160.dp -> 11.sp
            size.height < 220.dp -> 13.sp
            size.height < 320.dp -> 15.sp
            else -> 17.sp
        }

        Column(
            modifier = GlanceModifier
                .fillMaxWidth()
                .padding(bottom = if (isCompact) 1.dp else 4.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "${data.dayOfWeek}, ${data.gregorianDate}",
                style = TextStyle(
                    color = ColorProvider(accentGold),
                    fontSize = headerFontSize,
                    textAlign = TextAlign.Center,
                    fontWeight = FontWeight.Bold
                ),
                modifier = GlanceModifier.fillMaxWidth()
            )
            Text(
                text = data.hijriDate,
                style = TextStyle(
                    color = ColorProvider(textPrimary),
                    fontSize = headerFontSize,
                    textAlign = TextAlign.Center
                ),
                modifier = GlanceModifier.fillMaxWidth()
            )
        }

        Box(modifier = GlanceModifier.fillMaxWidth().height(1.dp).background(ColorProvider(accentGold))) {}
        Spacer(modifier = GlanceModifier.fillMaxWidth().height(2.dp))

        Column(
            modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            data.prayers.forEachIndexed { index, prayer ->
                val isNext = prayer.name == data.nextPrayerName
                
                Box(
                    modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                    contentAlignment = Alignment.Center
                ) {
                    PrayerRow(
                        name = prayer.name,
                        time = prayer.time,
                        isHighlighted = isNext,
                        primaryGreen = primaryGreen,
                        textPrimary = textPrimary,
                        fontSize = rowFontSize,
                        compact = isCompact,
                        isRtl = data.isRtl
                    )
                }

                if (index == 0) { // After Fajr
                    Box(
                        modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                        contentAlignment = Alignment.Center
                    ) {
                        PrayerRow(
                            name = if (data.isRtl) "الشروق" else "Sunrise",
                            time = data.sunrise,
                            isHighlighted = false,
                            primaryGreen = primaryGreen,
                            textPrimary = textSecondary,
                            fontSize = rowFontSize,
                            compact = isCompact,
                            isRtl = data.isRtl
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun PrayerRow(
        name: String,
        time: String,
        isHighlighted: Boolean,
        primaryGreen: Color,
        textPrimary: Color,
        fontSize: androidx.compose.ui.unit.TextUnit,
        compact: Boolean,
        isRtl: Boolean
    ) {
        val hPad = if (compact) 5.dp else 12.dp
        val dotSize = if (compact) 3.dp else 6.dp
        val dotGap = if (compact) 3.dp else 8.dp

        Row(
            modifier = GlanceModifier
                .fillMaxWidth()
                .background(ColorProvider(if (isHighlighted) primaryGreen else Color.Transparent))
                .cornerRadius(if (isHighlighted) 6.dp else 0.dp)
                .padding(horizontal = hPad),
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (!isRtl) {
                Text(
                    text = name,
                    modifier = GlanceModifier.defaultWeight(),
                    style = TextStyle(
                        color = ColorProvider(textPrimary),
                        fontSize = fontSize,
                        fontWeight = if (isHighlighted) FontWeight.Bold else FontWeight.Normal
                    )
                )
                if (isHighlighted) {
                    Box(modifier = GlanceModifier.size(dotSize).background(ColorProvider(Color.White)).cornerRadius(4.dp)) {}
                    Spacer(modifier = GlanceModifier.width(dotGap))
                }
                Text(
                    text = time,
                    style = TextStyle(
                        color = ColorProvider(textPrimary),
                        fontSize = fontSize,
                        fontWeight = if (isHighlighted) FontWeight.Bold else FontWeight.Normal
                    )
                )
            } else {
                Text(
                    text = time,
                    style = TextStyle(
                        color = ColorProvider(textPrimary),
                        fontSize = fontSize,
                        fontWeight = if (isHighlighted) FontWeight.Bold else FontWeight.Normal
                    )
                )
                if (isHighlighted) {
                    Spacer(modifier = GlanceModifier.width(dotGap))
                    Box(modifier = GlanceModifier.size(dotSize).background(ColorProvider(Color.White)).cornerRadius(4.dp)) {}
                }
                Text(
                    text = name,
                    modifier = GlanceModifier.defaultWeight(),
                    style = TextStyle(
                        color = ColorProvider(textPrimary),
                        fontSize = fontSize,
                        fontWeight = if (isHighlighted) FontWeight.Bold else FontWeight.Normal,
                        textAlign = TextAlign.End
                    )
                )
            }
        }
    }
}
