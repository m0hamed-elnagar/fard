package com.qada.fard.prayer

import android.util.Log
import com.batoulapps.adhan.PrayerTimes
import kotlin.math.abs

object PrayerParity {
    private const val TAG = "PrayerParity"
    private const val TOLERANCE_MS = 60_000L // 1 minute

    fun assert(dartTimes: Map<String, Any>, nativeTimes: PrayerTimes) {
        // BuildConfig not available in Flutter Android projects
        // if (!BuildConfig.DEBUG) return

        try {
            validatePrayer("Fajr", (dartTimes["fajr"] as? Long), nativeTimes.fajr.time)
            validatePrayer("Dhuhr", (dartTimes["dhuhr"] as? Long), nativeTimes.dhuhr.time)
            validatePrayer("Asr", (dartTimes["asr"] as? Long), nativeTimes.asr.time)
            validatePrayer("Maghrib", (dartTimes["maghrib"] as? Long), nativeTimes.maghrib.time)
            validatePrayer("Isha", (dartTimes["isha"] as? Long), nativeTimes.isha.time)
        } catch (e: Exception) {
            Log.e(TAG, "Parity check failed with exception", e)
        }
    }

    private fun validatePrayer(name: String, dartTime: Long?, nativeTime: Long) {
        if (dartTime == null) return
        
        val diff = abs(dartTime - nativeTime)
        if (diff > TOLERANCE_MS) {
            val message = "PARITY FAILURE: $name differs by ${diff / 1000}s between Dart and Kotlin"
            Log.e(TAG, message)
            // In a strict development environment, we could throw here
            // throw IllegalStateException(message)
        } else {
            Log.d(TAG, "Parity match: $name (diff: ${diff / 1000}s)")
        }
    }
}
