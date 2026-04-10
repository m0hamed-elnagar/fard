package com.qada.fard.baselineprofile

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.benchmark.macro.CompilationMode
import androidx.benchmark.macro.StartupMode
import androidx.benchmark.macro.StartupTimingMetric
import androidx.benchmark.macro.junit4.MacrobenchmarkRule
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
 * Macrobenchmark tests for baseline profile generation.
 *
 * Run automatically with: ./gradlew :app:generateBaselineProfile
 *
 * Traces the critical startup path through the app, recording which
 * classes and methods are loaded during cold startup.
 */
@RunWith(AndroidJUnit4::class)
@LargeTest
@SdkSuppress(minSdkVersion = Build.VERSION_CODES.N)
class StartupBenchmark {

    @get:Rule
    val benchmarkRule = MacrobenchmarkRule()

    @Test
    fun startupColdStart() = benchmarkRule.measureRepeated(
        packageName = "com.qada.fard",
        metrics = listOf(StartupTimingMetric()),
        iterations = 5,
        startupMode = StartupMode.COLD,
        // The Gradle plugin controls compilation mode during generation
        compilationMode = CompilationMode.None(),
    ) {
        pressHome()
        startActivityAndWait()

        // Wait for the Flutter UI to render
        // We wait for some content to appear. Since it's a Flutter app, 
        // we can wait for the root view or any identifiable text.
        device.wait(Until.hasObject(By.pkg("com.qada.fard").depth(0)), 5000)
        
        // Wait a bit more for the framework to initialize
        Thread.sleep(2000)

        // Basic interactions to capture more code
        // Scroll down if possible
        device.findObject(By.pkg("com.qada.fard"))?.scroll(Direction.DOWN, 0.5f)
        Thread.sleep(500)
        device.findObject(By.pkg("com.qada.fard"))?.scroll(Direction.UP, 0.5f)
        
        // Try to click some common locations (e.g., bottom tabs)
        val width = device.displayWidth
        val height = device.displayHeight
        
        // Click second tab (Quran) - approximate location
        device.click(width / 4, height - 100)
        Thread.sleep(1000)
        
        // Click third tab (Azkar)
        device.click(width / 2, height - 100)
        Thread.sleep(1000)
        
        // Click back to first tab
        device.click(100, height - 100)
        Thread.sleep(1000)
    }
}
