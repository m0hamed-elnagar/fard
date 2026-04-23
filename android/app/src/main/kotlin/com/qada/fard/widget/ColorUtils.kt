package com.qada.fard.widget

import androidx.core.graphics.toColorInt
import android.util.Log

object ColorUtils {
    private const val TAG = "ColorUtils"

    /**
     * Checks if a string is a valid hex color.
     */
    fun isValidHex(hex: String?): Boolean {
        if (hex == null || hex.isEmpty()) return false
        return try {
            val normalizedHex = if (hex.startsWith("#")) hex else "#$hex"
            normalizedHex.toColorInt()
            true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Safely parses a hex color string.
     * Returns the fallback color if the hex is malformed.
     */
    fun parseHexColor(hex: String, fallback: Int = android.graphics.Color.BLACK): Int {
        if (hex.isEmpty()) return fallback
        
        return try {
            val normalizedHex = if (hex.startsWith("#")) hex else "#$hex"
            normalizedHex.toColorInt()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to parse color hex: $hex. Using fallback.")
            fallback
        }
    }

    /**
     * Converts a hex string to a Compose Color object safely.
     */
    fun parseComposeColor(hex: String, fallback: androidx.compose.ui.graphics.Color = androidx.compose.ui.graphics.Color.Black): androidx.compose.ui.graphics.Color {
        return try {
            androidx.compose.ui.graphics.Color(parseHexColor(hex))
        } catch (e: Exception) {
            fallback
        }
    }
}
