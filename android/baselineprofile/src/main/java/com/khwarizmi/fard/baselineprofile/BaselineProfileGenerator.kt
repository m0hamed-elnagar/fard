package com.khwarizmi.fard.baselineprofile

import android.os.Build
import androidx.benchmark.macro.junit4.BaselineProfileRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.filters.LargeTest
import androidx.test.filters.SdkSuppress
import androidx.test.uiautomator.By
import androidx.test.uiautomator.Direction
import androidx.test.uiautomator.Until
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Baseline Profile generator for Fard app.
 *
 * Generates baseline profile rules during: ./gradlew :app:generateBaselineProfile
 */
@RunWith(AndroidJUnit4::class)
@LargeTest
@SdkSuppress(minSdkVersion = Build.VERSION_CODES.P)
class BaselineProfileGenerator {

    @get:Rule
    val baselineRule = BaselineProfileRule()

    @Test
    fun generate() = baselineRule.collect(
        packageName = "com.khwarizmi.fard",
        includeInStartupProfile = true,
    ) {
        pressHome()
        startActivityAndWait()

        // Wait for the Flutter UI to render
        device.wait(Until.hasObject(By.pkg("com.khwarizmi.fard").depth(0)), 5000)
        Thread.sleep(2000)

        // Interactions to capture startup path and core UI
        device.findObject(By.pkg("com.khwarizmi.fard"))?.scroll(Direction.DOWN, 0.8f)
        Thread.sleep(1000)
        device.findObject(By.pkg("com.khwarizmi.fard"))?.scroll(Direction.UP, 0.8f)
        Thread.sleep(1000)

        val width = device.displayWidth
        val height = device.displayHeight

        // Tab 2: Quran List
        device.click(width * 3 / 8, height - 100)
        Thread.sleep(2000)

        // Tab 3: Azkar
        device.click(width * 5 / 8, height - 100)
        Thread.sleep(1500)

        // Tab 4: Settings
        device.click(width * 7 / 8, height - 100)
        Thread.sleep(1500)

        // Back to Tab 1
        device.click(width / 8, height - 100)
        Thread.sleep(1000)
    }
}
