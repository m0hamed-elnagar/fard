package com.qada.fard.widget

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.LocalSize
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.TextAlign
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.qada.fard.MainActivity

/**
 * Sample prayer data for preview mode.
 */
val samplePrayerScheduleData = PrayerScheduleData(
    gregorianDate = "Apr 14, 2026",
    hijriDate = "26 شوال 1447",
    dayOfWeek = "Tuesday",
    sunrise = "06:15 AM",
    isRtl = false,
    nextPrayerName = "Asr",
    prayers = listOf(
        PrayerData("Fajr", "05:30 AM"),
        PrayerData("Dhuhr", "12:30 PM"),
        PrayerData("Asr", "03:45 PM"),
        PrayerData("Maghrib", "06:15 PM"),
        PrayerData("Isha", "07:30 PM")
    ),
    lastUpdated = System.currentTimeMillis()
)

/**
 * Sample countdown data for preview mode.
 */
val sampleCountdownData = CountdownData(
    nextPrayerName = "Asr",
    nextPrayerTime = System.currentTimeMillis() + (3 * 60 * 60 * 1000) + (45 * 60 * 1000), // 3h 45m from now
    isRtl = false,
    lastUpdated = System.currentTimeMillis()
)

// ==================== PRAYER SCHEDULE WIDGET CONTENT ====================

/**
 * SHARED COMPOSABLE for Prayer Schedule Widget.
 * Used by both:
 * 1. PlatformView preview in Flutter Settings
 * 2. GlanceAppWidget actual home widget
 *
 * @param data Prayer schedule data to display
 * @param theme Theme colors for the widget
 * @param isPreview Whether this is a preview (uses sample data behavior)
 */
@Composable
fun PrayerScheduleContent(
    data: PrayerScheduleData,
    theme: WidgetTheme,
    isPreview: Boolean = false
) {
    val colors = theme.toColors()
    val size = LocalSize.current
    val isTiny = size.width < 110.dp || size.height < 110.dp
    val isCompact = size.height < 220.dp
    val hPad = if (isCompact) 6.dp else 16.dp
    val vPad = if (isCompact) 4.dp else 14.dp

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(colors.background)
            .cornerRadius(16.dp)
            .clickable(actionStartActivity<MainActivity>())
            .padding(horizontal = hPad, vertical = vPad),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Check for stale data (> 24h) - skip in preview mode
        if (!isPreview && (data.lastUpdated == 0L || 
            System.currentTimeMillis() - data.lastUpdated > 24 * 60 * 60 * 1000)) {
            WidgetErrorContent(message = "Open App", colors = colors)
            return@Column
        }

        if (isTiny) {
            PrayerScheduleTinyLayout(data, size, colors)
        } else {
            PrayerScheduleFullLayout(data, size, isCompact, colors)
        }
    }
}

@Composable
private fun PrayerScheduleTinyLayout(
    data: PrayerScheduleData,
    size: DpSize,
    colors: WidgetColors
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
                Text(text = next.time, style = TextStyle(color = ColorProvider(colors.text), fontSize = 18.sp, fontWeight = FontWeight.Bold))
                Spacer(modifier = GlanceModifier.width(8.dp))
                Box(modifier = GlanceModifier.width(1.dp).height(16.dp).background(ColorProvider(colors.accent))) {}
                Spacer(modifier = GlanceModifier.width(8.dp))
                Text(text = next.name, style = TextStyle(color = ColorProvider(colors.accent), fontSize = 16.sp, fontWeight = FontWeight.Bold))
            } else {
                Text(text = next.name, style = TextStyle(color = ColorProvider(colors.accent), fontSize = 16.sp, fontWeight = FontWeight.Bold))
                Spacer(modifier = GlanceModifier.width(8.dp))
                Box(modifier = GlanceModifier.width(1.dp).height(16.dp).background(ColorProvider(colors.accent))) {}
                Spacer(modifier = GlanceModifier.width(8.dp))
                Text(text = next.time, style = TextStyle(color = ColorProvider(colors.text), fontSize = 18.sp, fontWeight = FontWeight.Bold))
            }
        }
    } else {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (isRtl) {
                Text(text = next.time, style = TextStyle(color = ColorProvider(colors.text), fontSize = 16.sp, fontWeight = FontWeight.Bold))
                Spacer(modifier = GlanceModifier.height(3.dp))
                Box(modifier = GlanceModifier.width(36.dp).height(1.dp).background(ColorProvider(colors.accent))) {}
                Spacer(modifier = GlanceModifier.height(3.dp))
                Text(text = next.name, style = TextStyle(color = ColorProvider(colors.accent), fontSize = 12.sp, fontWeight = FontWeight.Bold))
            } else {
                Text(text = next.name, style = TextStyle(color = ColorProvider(colors.accent), fontSize = 12.sp, fontWeight = FontWeight.Bold))
                Spacer(modifier = GlanceModifier.height(3.dp))
                Box(modifier = GlanceModifier.width(36.dp).height(1.dp).background(ColorProvider(colors.accent))) {}
                Spacer(modifier = GlanceModifier.height(3.dp))
                Text(text = next.time, style = TextStyle(color = ColorProvider(colors.text), fontSize = 16.sp, fontWeight = FontWeight.Bold))
            }
        }
    }
}

@Composable
private fun ColumnScope.PrayerScheduleFullLayout(
    data: PrayerScheduleData,
    size: DpSize,
    isCompact: Boolean,
    colors: WidgetColors
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
                color = ColorProvider(colors.accent),
                fontSize = headerFontSize,
                textAlign = TextAlign.Center,
                fontWeight = FontWeight.Bold
            ),
            modifier = GlanceModifier.fillMaxWidth()
        )
        Text(
            text = data.hijriDate,
            style = TextStyle(
                color = ColorProvider(colors.text),
                fontSize = headerFontSize,
                textAlign = TextAlign.Center
            ),
            modifier = GlanceModifier.fillMaxWidth()
        )
    }

    Box(modifier = GlanceModifier.fillMaxWidth().height(1.dp).background(ColorProvider(colors.accent))) {}
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
                PrayerScheduleRow(
                    name = prayer.name,
                    time = prayer.time,
                    isHighlighted = isNext,
                    colors = colors,
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
                    PrayerScheduleRow(
                        name = if (data.isRtl) "الشروق" else "Sunrise",
                        time = data.sunrise,
                        isHighlighted = false,
                        colors = colors.copy(text = colors.textSecondary),
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
private fun PrayerScheduleRow(
    name: String,
    time: String,
    isHighlighted: Boolean,
    colors: WidgetColors,
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
            .background(ColorProvider(if (isHighlighted) colors.primary else Color.Transparent))
            .cornerRadius(if (isHighlighted) 6.dp else 0.dp)
            .padding(horizontal = hPad),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (!isRtl) {
            Text(
                text = name,
                modifier = GlanceModifier.defaultWeight(),
                style = TextStyle(
                    color = ColorProvider(colors.text),
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
                    color = ColorProvider(colors.text),
                    fontSize = fontSize,
                    fontWeight = if (isHighlighted) FontWeight.Bold else FontWeight.Normal
                )
            )
        } else {
            Text(
                text = time,
                style = TextStyle(
                    color = ColorProvider(colors.text),
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
                    color = ColorProvider(colors.text),
                    fontSize = fontSize,
                    fontWeight = if (isHighlighted) FontWeight.Bold else FontWeight.Normal,
                    textAlign = TextAlign.End
                )
            )
        }
    }
}

// ==================== COUNTDOWN WIDGET CONTENT ====================

/**
 * SHARED COMPOSABLE for Next Prayer Countdown Widget.
 * Used by both:
 * 1. PlatformView preview in Flutter Settings
 * 2. GlanceAppWidget actual home widget
 *
 * @param data Countdown data to display
 * @param theme Theme colors for the widget
 * @param isPreview Whether this is a preview (uses sample data behavior)
 */
@Composable
fun CountdownContent(
    data: CountdownData,
    theme: WidgetTheme,
    isPreview: Boolean = false
) {
    val colors = theme.toColors()
    val size = LocalSize.current

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
            .background(colors.background)
            .cornerRadius(16.dp)
            .clickable(actionStartActivity<MainActivity>())
            .padding(padding),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Check for stale data - skip in preview mode
        if (!isPreview && (data.nextPrayerTime == 0L || 
            System.currentTimeMillis() - data.lastUpdated > 24 * 60 * 60 * 1000)) {
            WidgetErrorContent(message = "Open App", colors = colors)
            return@Column
        }

        // Calculate countdown time
        val prayerCal = java.util.Calendar.getInstance().apply { timeInMillis = data.nextPrayerTime }
        val nowCal = java.util.Calendar.getInstance()

        prayerCal.set(java.util.Calendar.SECOND, 0)
        prayerCal.set(java.util.Calendar.MILLISECOND, 0)
        nowCal.set(java.util.Calendar.SECOND, 0)
        nowCal.set(java.util.Calendar.MILLISECOND, 0)

        val totalMinutes = (prayerCal.timeInMillis - nowCal.timeInMillis) / 60000

        val statusText = when {
            totalMinutes > 0 -> {
                val hours = totalMinutes / 60
                val minutes = totalMinutes % 60
                if (hours > 0) "${hours}h ${minutes}m" else "${minutes}m"
            }
            // Treat up to 1 minute after prayer as 'Now' to smooth transition
            totalMinutes >= -1 -> "Now"
            else -> {
                Text(
                    text = "Syncing...",
                    style = TextStyle(
                        color = ColorProvider(colors.text),
                        fontSize = if (isTiny) 10.sp else 12.sp,
                        textAlign = TextAlign.Center
                    )
                )
                return@Column
            }
        }

        if (isWide) {
            CountdownWideLayout(data, statusText, colors)
        } else if (isTiny) {
            CountdownTinyLayout(data, statusText, colors)
        } else {
            CountdownStandardLayout(data, statusText, isSmall, isLarge, colors)
        }
    }
}

@Composable
private fun CountdownTinyLayout(
    data: CountdownData,
    statusText: String,
    colors: WidgetColors
) {
    Column(
        modifier = GlanceModifier.fillMaxSize(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = data.nextPrayerName,
            style = TextStyle(
                color = ColorProvider(colors.accent),
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
                .background(ColorProvider(colors.accent))
        ) {}
        Spacer(modifier = GlanceModifier.height(4.dp))
        Text(
            text = statusText,
            style = TextStyle(
                color = ColorProvider(colors.text),
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )
        )
    }
}

@Composable
private fun CountdownWideLayout(
    data: CountdownData,
    statusText: String,
    colors: WidgetColors
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
                    color = ColorProvider(colors.text),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            )
            Spacer(modifier = GlanceModifier.width(12.dp))
            Box(
                modifier = GlanceModifier
                    .width(1.dp)
                    .height(20.dp)
                    .background(ColorProvider(colors.accent))
            ) {}
            Spacer(modifier = GlanceModifier.width(12.dp))
            Text(
                text = data.nextPrayerName,
                style = TextStyle(
                    color = ColorProvider(colors.accent),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            )
        } else {
            Text(
                text = data.nextPrayerName,
                style = TextStyle(
                    color = ColorProvider(colors.accent),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            )
            Spacer(modifier = GlanceModifier.width(12.dp))
            Box(
                modifier = GlanceModifier
                    .width(1.dp)
                    .height(20.dp)
                    .background(ColorProvider(colors.accent))
            ) {}
            Spacer(modifier = GlanceModifier.width(12.dp))
            Text(
                text = statusText,
                style = TextStyle(
                    color = ColorProvider(colors.text),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            )
        }
    }
}

@Composable
private fun CountdownStandardLayout(
    data: CountdownData,
    statusText: String,
    isSmall: Boolean,
    isLarge: Boolean,
    colors: WidgetColors
) {
    val label = if (data.isRtl) "الصلاة القادمة" else "Next Prayer"
    if (!isSmall) {
        Text(
            text = label,
            style = TextStyle(color = ColorProvider(colors.text), fontSize = 12.sp)
        )
    }

    val nameFontSize = if (isSmall) 16.sp else if (isLarge) 24.sp else 20.sp

    Text(
        text = data.nextPrayerName,
        style = TextStyle(
            color = ColorProvider(colors.accent),
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
            color = ColorProvider(colors.text),
            fontSize = timeFontSize,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center
        )
    )
}

/**
 * Common error state for all widgets.
 */
@Composable
fun WidgetErrorContent(
    message: String,
    colors: WidgetColors
) {
    Column(
        modifier = GlanceModifier.fillMaxSize(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = message,
            style = TextStyle(
                color = ColorProvider(colors.text),
                fontSize = 14.sp,
                textAlign = TextAlign.Center
            )
        )
        Spacer(modifier = GlanceModifier.height(8.dp))
        Text(
            text = "Tap to Sync",
            style = TextStyle(
                color = ColorProvider(colors.accent),
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )
        )
    }
}
