package com.qada.fard

import android.app.Application
import android.util.Log
import androidx.work.*
import com.qada.fard.widget.WidgetUpdateWorker
import java.util.concurrent.TimeUnit

class FardApplication : Application() {
    
    companion object {
        private const val TAG = "FardApplication"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Application onCreate")

        // Schedule WorkManager safety net (15-min periodic)
        scheduleWidgetSafetyNet()
    }

    private fun scheduleWidgetSafetyNet() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
            .build()

        val workRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(15, TimeUnit.MINUTES)
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "widget_safety_net",
            ExistingPeriodicWorkPolicy.REPLACE,  // Always use latest configuration
            workRequest
        )
        Log.d(TAG, "Scheduled 15-min safety net worker")
    }
}
