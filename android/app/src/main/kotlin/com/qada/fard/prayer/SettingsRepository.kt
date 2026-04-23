package com.qada.fard.prayer

import android.content.Context
import android.content.SharedPreferences

class SettingsRepository(private val context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    fun getSettings(): CalculationSettings? {
        val lat =
            (prefs.getString(CalculationContract.PREF_PREFIX + "latitude", null))?.toDoubleOrNull()
                ?: return null
        val lon =
            (prefs.getString(CalculationContract.PREF_PREFIX + "longitude", null))?.toDoubleOrNull()
                ?: return null

        val methodString =
            prefs.getString(CalculationContract.PREF_PREFIX + "calculation_method", "muslim_league")
                ?: "muslim_league"
        val madhabString =
            prefs.getString(CalculationContract.PREF_PREFIX + "madhab", "shafi") ?: "shafi"

        // Map string names to Contract IDs
        val methodId = mapMethodStringToId(methodString)
        val madhabId =
            if (madhabString == "hanafi") CalculationContract.MADHAB_HANAFI else CalculationContract.MADHAB_SHAFI

        // In this app, high latitude rule might not be explicitly set in basic SharedPreferences
        // ,but we can default it or read if available.
        val highLatId = prefs.getInt(
            CalculationContract.PREF_PREFIX + "high_latitude_method",
            CalculationContract.HIGH_LAT_MIDDLE_OF_THE_NIGHT
        )

        val locale = prefs.getString(CalculationContract.PREF_PREFIX + "locale", "ar") ?: "ar"

        return CalculationSettings(
            latitude = lat,
            longitude = lon,
            method = methodId,
            madhab = madhabId,
            highLatitudeRule = highLatId,
            locale = locale
        )
    }

    fun getPrayerDataJson(): String? {
        // Debugging the path
        val file = context.getSharedPreferences(
            "FlutterSharedPreferences",
            android.content.Context.MODE_PRIVATE
        )
        android.util.Log.d(
            "WidgetDebug",
            "SettingsRepository SharedPreferences Path: " + context.filesDir.parent + "/shared_prefs/FlutterSharedPreferences.xml"
        )

        val json = prefs.getString(CalculationContract.PREF_PREFIX + "prayer_data", null)
        android.util.Log.d(
            "WidgetDebug",
            "SettingsRepository getPrayerDataJson key: " + CalculationContract.PREF_PREFIX + "prayer_data" + " Found: " + json
        )
        return json
    }

    /**
     * Save settings to SharedPreferences.
     * This is called from MainActivity when settings are received from Flutter.
     */
    fun saveSettings(
        latitude: Double,
        longitude: Double,
        calculationMethod: Int,
        madhab: Int,
        locale: String,
        prayerData: String? = null,
        hijriDate: String? = null,
        highLatitudeRule: Int = CalculationContract.HIGH_LAT_MIDDLE_OF_THE_NIGHT
    ) {
        prefs.edit().apply {
            putString(CalculationContract.PREF_PREFIX + "latitude", latitude.toString())
            putString(CalculationContract.PREF_PREFIX + "longitude", longitude.toString())
            putString(
                CalculationContract.PREF_PREFIX + "calculation_method",
                mapMethodIdToString(calculationMethod)
            )
            putString(
                CalculationContract.PREF_PREFIX + "madhab",
                if (madhab == CalculationContract.MADHAB_HANAFI) "hanafi" else "shafi"
            )
            putInt(CalculationContract.PREF_PREFIX + "high_latitude_method", highLatitudeRule)
            putString(CalculationContract.PREF_PREFIX + "locale", locale)
            if (prayerData != null) {
                putString(CalculationContract.PREF_PREFIX + "prayer_data", prayerData)
            }
            if (hijriDate != null) {
                putString("flutter.hijri_date_cache", hijriDate)
            }
            commit() // Synchronous write to ensure immediate visibility to widgets
        }
    }

    /**
     * Get cached Hijri date from SharedPreferences.
     * This is used by WidgetUpdateWorker to avoid showing "Loading..."
     */
    fun getCachedHijriDate(): String? {
        return prefs.getString("flutter.hijri_date_cache", null)
    }

    /**
     * Check if a custom widget theme is currently saved in SharedPreferences.
     */
    fun hasWidgetThemeOverride(): Boolean {
        return prefs.contains("flutter.widget_theme_primary")
    }

    /**
     * Save widget theme to SharedPreferences.
     * This allows widgets to read independent theme colors.
     */
    fun saveWidgetTheme(themeData: Map<String, Any>) {
        val cu = com.qada.fard.widget.ColorUtils
        prefs.edit().apply {
            val primary = themeData["primaryColorHex"] as? String
            putString("flutter.widget_theme_primary", if (cu.isValidHex(primary)) primary else "#2E7D32")
            
            val accent = themeData["accentColorHex"] as? String
            putString("flutter.widget_theme_accent", if (cu.isValidHex(accent)) accent else "#FFD54F")
            
            val background = themeData["backgroundColorHex"] as? String
            putString("flutter.widget_theme_background", if (cu.isValidHex(background)) background else "#0D1117")
            
            val surface = themeData["surfaceColorHex"] as? String
            putString("flutter.widget_theme_surface", if (cu.isValidHex(surface)) surface else "#161B22")
            
            val text = themeData["textColorHex"] as? String
            putString("flutter.widget_theme_text", if (cu.isValidHex(text)) text else "#FFFFFF")
            
            val secondary = themeData["textSecondaryColorHex"] as? String
            putString("flutter.widget_theme_text_secondary", if (cu.isValidHex(secondary)) secondary else "#8B949E")
            
            putLong("flutter/widget_theme_timestamp", System.currentTimeMillis())
            commit()
        }
    }

    /**
     * Get widget theme from SharedPreferences.
     * Returns a WidgetTheme object.
     */
    fun getWidgetTheme(): com.qada.fard.widget.WidgetTheme {
        return com.qada.fard.widget.WidgetTheme(
            primaryColorHex = prefs.getString("flutter.widget_theme_primary", "#2E7D32")
                ?: "#2E7D32",
            accentColorHex = prefs.getString("flutter.widget_theme_accent", "#FFD54F") ?: "#FFD54F",
            backgroundColorHex = prefs.getString("flutter.widget_theme_background", "#0D1117")
                ?: "#0D1117",
            surfaceColorHex = prefs.getString("flutter.widget_theme_surface", "#161B22")
                ?: "#161B22",
            textColorHex = prefs.getString("flutter.widget_theme_text", "#FFFFFF") ?: "#FFFFFF",
            textSecondaryColorHex = prefs.getString(
                "flutter.widget_theme_text_secondary",
                "#8B949E"
            ) ?: "#8B949E"
        )
    }

    /**
     * Resolves the theme to use for a widget, considering overrides and fallbacks.
     */
    fun resolveWidgetTheme(fallback: com.qada.fard.widget.WidgetTheme): com.qada.fard.widget.WidgetTheme {
        return if (hasWidgetThemeOverride()) {
            getWidgetTheme()
        } else {
            fallback
        }
    }

    /**
     * Clear widget theme from SharedPreferences.
     * Widgets will fall back to app theme colors.
     */
    fun clearWidgetTheme() {
        prefs.edit().apply {
            remove("flutter.widget_theme_primary")
            remove("flutter.widget_theme_accent")
            remove("flutter.widget_theme_background")
            remove("flutter.widget_theme_surface")
            remove("flutter.widget_theme_text")
            remove("flutter.widget_theme_text_secondary")
            remove("flutter.widget_theme_timestamp")
            commit()
        }
    }

    private fun mapMethodStringToId(method: String): Int {
        return when (method) {
            "muslim_league" -> CalculationContract.METHOD_MUSLIM_WORLD_LEAGUE
            "egyptian" -> CalculationContract.METHOD_EGYPTIAN
            "karachi" -> CalculationContract.METHOD_KARACHI
            "umm_al_qura" -> CalculationContract.METHOD_UMM_AL_QURA
            "dubai" -> CalculationContract.METHOD_DUBAI
            "moonsighting_committee" -> CalculationContract.METHOD_MOON_SIGHTING_COMMITTEE
            "north_america" -> CalculationContract.METHOD_NORTH_AMERICA
            "kuwait" -> CalculationContract.METHOD_KUWAIT
            "qatar" -> CalculationContract.METHOD_QATAR
            "singapore" -> CalculationContract.METHOD_SINGAPORE
            "tehran" -> CalculationContract.METHOD_TEHRAN
            "turkey" -> CalculationContract.METHOD_TURKEY
            else -> CalculationContract.METHOD_MUSLIM_WORLD_LEAGUE
        }
    }

    private fun mapMethodIdToString(methodId: Int): String {
        return when (methodId) {
            CalculationContract.METHOD_MUSLIM_WORLD_LEAGUE -> "muslim_league"
            CalculationContract.METHOD_EGYPTIAN -> "egyptian"
            CalculationContract.METHOD_KARACHI -> "karachi"
            CalculationContract.METHOD_UMM_AL_QURA -> "umm_al_qura"
            CalculationContract.METHOD_DUBAI -> "dubai"
            CalculationContract.METHOD_MOON_SIGHTING_COMMITTEE -> "moonsighting_committee"
            CalculationContract.METHOD_NORTH_AMERICA -> "north_america"
            CalculationContract.METHOD_KUWAIT -> "kuwait"
            CalculationContract.METHOD_QATAR -> "qatar"
            CalculationContract.METHOD_SINGAPORE -> "singapore"
            CalculationContract.METHOD_TEHRAN -> "tehran"
            CalculationContract.METHOD_TURKEY -> "turkey"
            else -> "muslim_league"
        }
    }
}
