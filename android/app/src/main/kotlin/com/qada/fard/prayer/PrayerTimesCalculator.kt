package com.qada.fard.prayer

import com.batoulapps.adhan.*
import com.batoulapps.adhan.data.DateComponents
import java.util.*

object PrayerTimesCalculator {
    private var cachedPrayerTimes: PrayerTimes? = null
    private var lastCalculationDay: Int = -1

    fun invalidateCache() {
        cachedPrayerTimes = null
        lastCalculationDay = -1
    }

    fun calculateToday(settings: CalculationSettings): PrayerTimes {
        val calendar = Calendar.getInstance()
        return calculateForCalendar(settings, calendar)
    }

    fun calculateTomorrow(settings: CalculationSettings): PrayerTimes {
        val calendar = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
        }
        return calculateForCalendar(settings, calendar)
    }

    private fun calculateForCalendar(settings: CalculationSettings, calendar: Calendar): PrayerTimes {
        val currentDay = calendar.get(Calendar.DAY_OF_YEAR)

        // Return cached if settings haven't changed and it's still the same day
        if (cachedPrayerTimes != null && lastCalculationDay == currentDay) {
            return cachedPrayerTimes!!
        }

        val coordinates = Coordinates(settings.latitude, settings.longitude)
        val dateComponents = DateComponents.from(calendar.time)
        val params = getCalculationParameters(settings)

        val prayerTimes = PrayerTimes(coordinates, dateComponents, params)

        cachedPrayerTimes = prayerTimes
        lastCalculationDay = currentDay

        return prayerTimes
    }

    private fun getCalculationParameters(settings: CalculationSettings): CalculationParameters {
        val method = when (settings.method) {
            CalculationContract.METHOD_MUSLIM_WORLD_LEAGUE -> CalculationMethod.MUSLIM_WORLD_LEAGUE
            CalculationContract.METHOD_EGYPTIAN -> CalculationMethod.EGYPTIAN
            CalculationContract.METHOD_KARACHI -> CalculationMethod.KARACHI
            CalculationContract.METHOD_UMM_AL_QURA -> CalculationMethod.UMM_AL_QURA
            CalculationContract.METHOD_DUBAI -> CalculationMethod.DUBAI
            CalculationContract.METHOD_MOON_SIGHTING_COMMITTEE -> CalculationMethod.MOON_SIGHTING_COMMITTEE
            CalculationContract.METHOD_NORTH_AMERICA -> CalculationMethod.NORTH_AMERICA
            CalculationContract.METHOD_KUWAIT -> CalculationMethod.KUWAIT
            CalculationContract.METHOD_QATAR -> CalculationMethod.QATAR
            CalculationContract.METHOD_SINGAPORE -> CalculationMethod.SINGAPORE
            CalculationContract.METHOD_TEHRAN -> {
                // Fajr: 17.7, Isha: 14
                CalculationMethod.OTHER.parameters.apply {
                    fajrAngle = 17.7
                    ishaAngle = 14.0
                }
                CalculationMethod.OTHER
            }
            CalculationContract.METHOD_TURKEY -> {
                // Fajr: 18, Isha: 17
                CalculationMethod.OTHER.parameters.apply {
                    fajrAngle = 18.0
                    ishaAngle = 17.0
                }
                CalculationMethod.OTHER
            }
            else -> CalculationMethod.MUSLIM_WORLD_LEAGUE
        }.parameters

        method.madhab = if (settings.madhab == CalculationContract.MADHAB_HANAFI) Madhab.HANAFI else Madhab.SHAFI

        method.highLatitudeRule = when (settings.highLatitudeRule) {
            CalculationContract.HIGH_LAT_MIDDLE_OF_THE_NIGHT -> HighLatitudeRule.MIDDLE_OF_THE_NIGHT
            CalculationContract.HIGH_LAT_SEVENTH_OF_THE_NIGHT -> HighLatitudeRule.SEVENTH_OF_THE_NIGHT
            CalculationContract.HIGH_LAT_TWILIGHT_ANGLE -> HighLatitudeRule.TWILIGHT_ANGLE
            else -> HighLatitudeRule.MIDDLE_OF_THE_NIGHT
        }

        // Apply offsets if provided
        settings.offsets["fajr"]?.let { method.adjustments.fajr = it }
        settings.offsets["dhuhr"]?.let { method.adjustments.dhuhr = it }
        settings.offsets["asr"]?.let { method.adjustments.asr = it }
        settings.offsets["maghrib"]?.let { method.adjustments.maghrib = it }
        settings.offsets["isha"]?.let { method.adjustments.isha = it }
        settings.offsets["sunrise"]?.let { method.adjustments.sunrise = it }

        return method
    }
}
