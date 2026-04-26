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
        // 1. Scroll main screen
        device.findObject(By.pkg("com.qada.fard"))?.scroll(Direction.DOWN, 0.8f)
        Thread.sleep(1000)
        device.findObject(By.pkg("com.qada.fard"))?.scroll(Direction.UP, 0.8f)
        Thread.sleep(1000)

        // 2. Navigate through tabs
        val width = device.displayWidth
        val height = device.displayHeight
        
        // Tab 2: Quran List
        device.click(width * 3 / 8, height - 100)
        Thread.sleep(2000)
        device.findObject(By.pkg("com.qada.fard"))?.scroll(Direction.DOWN, 0.5f)
        
        // Click a surah (approximate position for first item)
        device.click(width / 2, height / 3)
        Thread.sleep(3000) // Wait for Quran reader to load
        
        // Scroll in Quran reader to warm up text rendering
        device.findObject(By.pkg("com.qada.fard"))?.scroll(Direction.DOWN, 0.8f)
        Thread.sleep(1000)
        device.findObject(By.pkg("com.qada.fard"))?.scroll(Direction.DOWN, 0.8f)
        Thread.sleep(1000)
        
        // Go back
        device.pressBack()
        Thread.sleep(1000)
        
        // Tab 3: Azkar
        device.click(width * 5 / 8, height - 100)
        Thread.sleep(1500)
        
        // Tab 4: Settings/More
        device.click(width * 7 / 8, height - 100)
        Thread.sleep(1500)
        
        // Back to Tab 1
        device.click(width / 8, height - 100)
        Thread.sleep(1000)
    }
}
