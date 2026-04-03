package com.qada.fard.prayer

import android.content.Context
import android.content.SharedPreferences

class SettingsRepository(private val context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    fun getSettings(): CalculationSettings? {
        val lat = (prefs.getString(CalculationContract.PREF_PREFIX + "latitude", null))?.toDoubleOrNull()
            ?: return null
        val lon = (prefs.getString(CalculationContract.PREF_PREFIX + "longitude", null))?.toDoubleOrNull()
            ?: return null

        val methodString = prefs.getString(CalculationContract.PREF_PREFIX + "calculation_method", "muslim_league") ?: "muslim_league"
        val madhabString = prefs.getString(CalculationContract.PREF_PREFIX + "madhab", "shafi") ?: "shafi"

        // Map string names to Contract IDs
        val methodId = mapMethodStringToId(methodString)
        val madhabId = if (madhabString == "hanafi") CalculationContract.MADHAB_HANAFI else CalculationContract.MADHAB_SHAFI

        // In this app, high latitude rule might not be explicitly set in basic SharedPreferences
        // but we can default it or read if available.
        val highLatId = prefs.getInt(CalculationContract.PREF_PREFIX + "high_latitude_method", CalculationContract.HIGH_LAT_MIDDLE_OF_THE_NIGHT)

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
        val file = context.getSharedPreferences("FlutterSharedPreferences", android.content.Context.MODE_PRIVATE)
        android.util.Log.d("WidgetDebug", "SettingsRepository SharedPreferences Path: " + context.filesDir.parent + "/shared_prefs/FlutterSharedPreferences.xml")
        
        val json = prefs.getString(CalculationContract.PREF_PREFIX + "prayer_data", null)
        android.util.Log.d("WidgetDebug", "SettingsRepository getPrayerDataJson key: " + CalculationContract.PREF_PREFIX + "prayer_data" + " Found: " + json)
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
        highLatitudeRule: Int = CalculationContract.HIGH_LAT_MIDDLE_OF_THE_NIGHT
    ) {
        prefs.edit().apply {
            putString(CalculationContract.PREF_PREFIX + "latitude", latitude.toString())
            putString(CalculationContract.PREF_PREFIX + "longitude", longitude.toString())
            putString(CalculationContract.PREF_PREFIX + "calculation_method", mapMethodIdToString(calculationMethod))
            putString(CalculationContract.PREF_PREFIX + "madhab", if (madhab == CalculationContract.MADHAB_HANAFI) "hanafi" else "shafi")
            putInt(CalculationContract.PREF_PREFIX + "high_latitude_method", highLatitudeRule)
            putString(CalculationContract.PREF_PREFIX + "locale", locale)
            if (prayerData != null) {
                putString(CalculationContract.PREF_PREFIX + "prayer_data", prayerData)
            }
            commit() // Synchronous write to ensure immediate visibility to widgets
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
