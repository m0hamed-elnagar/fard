package com.qada.fard.prayer

/**
 * THIS FILE IS THE SINGLE SOURCE OF TRUTH - mirror of calculation_contract.dart
 * Do not change values without updating the mirror file in lib/core/constants/calculation_contract.dart
 */
object CalculationContract {
    // Calculation Methods
    const val METHOD_MUSLIM_WORLD_LEAGUE = 0
    const val METHOD_EGYPTIAN = 1
    const val METHOD_KARACHI = 2
    const val METHOD_UMM_AL_QURA = 3
    const val METHOD_DUBAI = 4
    const val METHOD_MOON_SIGHTING_COMMITTEE = 5
    const val METHOD_NORTH_AMERICA = 6
    const val METHOD_KUWAIT = 7
    const val METHOD_QATAR = 8
    const val METHOD_SINGAPORE = 9
    const val METHOD_TEHRAN = 10
    const val METHOD_TURKEY = 11
    const val METHOD_USER_CUSTOM = 12

    // Madhabs
    const val MADHAB_SHAFI = 0
    const val MADHAB_HANAFI = 1

    // High Latitude Rules
    const val HIGH_LAT_MIDDLE_OF_THE_NIGHT = 0
    const val HIGH_LAT_SEVENTH_OF_THE_NIGHT = 1
    const val HIGH_LAT_TWILIGHT_ANGLE = 2

    // Channel & Pref Keys
    const val CHANNEL_NAME = "com.qada.fard/instant_updates"
    const val PREF_PREFIX = "flutter."
}
