package com.qada.fard.prayer

data class CalculationSettings(
    val latitude: Double,
    val longitude: Double,
    val method: Int,
    val madhab: Int,
    val highLatitudeRule: Int,
    val offsets: Map<String, Int> = emptyMap(),
    val timeFormat: String = "12h",
    val locale: String = "ar"
)
