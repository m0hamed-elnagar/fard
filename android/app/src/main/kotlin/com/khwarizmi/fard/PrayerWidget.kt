package com.khwarizmi.fard

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import com.khwarizmi.fard.prayer.SettingsRepository
import com.khwarizmi.fard.widget.PrayerScheduleContent
import com.khwarizmi.fard.widget.WidgetParser

class PrayerWidget : GlanceAppWidget() {

    override val sizeMode: SizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val repository = SettingsRepository(context)
        val prayerDataJson = repository.getPrayerDataJson()

        val widgetData = if (prayerDataJson != null) {
            WidgetParser.parsePrayerScheduleData(prayerDataJson)
        } else null

        val fallbackTheme = if (prayerDataJson != null) {
            WidgetParser.parseTheme(prayerDataJson)
        } else com.khwarizmi.fard.widget.WidgetTheme()

        provideContent {
            if (widgetData != null) {
                val themeToUse = repository.resolveWidgetTheme(fallbackTheme)
                
                PrayerScheduleContent(
                    data = widgetData,
                    theme = themeToUse,
                    isPreview = false
                )
            }
        }
    }
}

