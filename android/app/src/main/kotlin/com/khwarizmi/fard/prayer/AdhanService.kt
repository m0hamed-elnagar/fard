package com.khwarizmi.fard.prayer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.media.app.NotificationCompat.MediaStyle
import android.media.RingtoneManager
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import androidx.work.Data
import com.khwarizmi.fard.MainActivity
import com.khwarizmi.fard.R
import java.io.File

class AdhanService : Service() {

    private var mediaPlayer: MediaPlayer? = null
    private lateinit var audioManager: AudioManager
    private var focusRequest: AudioFocusRequest? = null
    private var isScreenReceiverRegistered = false
    private var isAdhanPlaying = false

    companion object {
        private const val TAG = "AdhanService"
        private const val NOTIFICATION_ID = 2026
    }

    private val focusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
        Log.d(TAG, "onAudioFocusChange: focusChange=$focusChange")
        when (focusChange) {
            AudioManager.AUDIOFOCUS_LOSS -> {
                Log.d(TAG, "Audio focus lost permanently. Stopping Adhan.")
                stopAdhan()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                Log.d(TAG, "Audio focus lost transiently. Pausing Adhan.")
                pauseAdhan()
            }
            AudioManager.AUDIOFOCUS_GAIN -> {
                Log.d(TAG, "Audio focus gained. Resuming Adhan.")
                resumeAdhan()
            }
        }
    }

    private val screenOffReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == Intent.ACTION_SCREEN_OFF) {
                Log.d(TAG, "Screen turned off. Stopping Adhan.")
                stopAdhan()
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "onCreate")
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        // Register screen off receiver
        try {
            val filter = IntentFilter(Intent.ACTION_SCREEN_OFF)
            registerReceiver(screenOffReceiver, filter)
            isScreenReceiverRegistered = true
            Log.d(TAG, "Screen off receiver registered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register screen off receiver", e)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            stopSelf()
            return START_NOT_STICKY
        }

        val action = intent.action
        Log.d(TAG, "onStartCommand: action=$action")

        if (action == "$packageName.action.STOP_ADHAN") {
            Log.d(TAG, "onStartCommand: STOP action received")
            stopAdhan()
            return START_NOT_STICKY
        }

        if (action == "$packageName.action.MARK_PRAYED_AND_STOP") {
            Log.d(TAG, "onStartCommand: MARK_PRAYED_AND_STOP action received")
            val prayerName = intent.getStringExtra("prayerName") ?: ""
            stopAdhan()
            
            // 1. Convert Arabic name to English lower key
            val prayerKey = when (prayerName) {
                "الفجر" -> "fajr"
                "الظهر" -> "dhuhr"
                "العصر" -> "asr"
                "المغرب" -> "maghrib"
                "العشاء" -> "isha"
                else -> prayerName.lowercase()
            }
            
            // 2. Save it to SharedPreferences
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val pending = prefs.getString("flutter.pending_completed_prayers", "") ?: ""
            val newPending = if (pending.isEmpty()) prayerKey else "$pending,$prayerKey"
            prefs.edit().putString("flutter.pending_completed_prayers", newPending).apply()

            val completed = prefs.getString("flutter.completed_today", "") ?: ""
            val newCompleted = if (completed.isEmpty()) prayerKey else "$completed,$prayerKey"
            prefs.edit().putString("flutter.completed_today", newCompleted).apply()

            // Show native Toast feedback
            val isAr = prefs.getString("flutter.locale", "ar") == "ar"
            val message = if (isAr) "تم تسجيل صلاة $prayerName بنجاح" else "$prayerName marked as prayed successfully"
            android.widget.Toast.makeText(this, message, android.widget.Toast.LENGTH_SHORT).show()

            // 3. Trigger Flutter background task via WorkManager (using reflection to avoid compile dependency issues)
            try {
                @Suppress("UNCHECKED_CAST")
                val workerClass = Class.forName("be.tramckrijte.workmanager.BackgroundWorker") as Class<out androidx.work.ListenableWorker>
                val workRequest = OneTimeWorkRequest.Builder(workerClass)
                    .setInputData(
                        Data.Builder()
                            .putString("be.tramckrijte.workmanager.BACKGROUND_ISOLATE_TASK_NAME", "widget_refresh_task")
                            .build()
                    )
                    .build()
                WorkManager.getInstance(this).enqueue(workRequest)
                Log.d(TAG, "WorkManager task enqueued successfully from AdhanService")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to enqueue WorkManager task from AdhanService", e)
            }

            stopSelf()
            return START_NOT_STICKY
        }

        val prayerName = intent.getStringExtra("prayerName") ?: ""
        val audioFilePath = intent.getStringExtra("audioFilePath") ?: ""
        val isTest = intent.getBooleanExtra("isTest", false)

        Log.d(TAG, "onStartCommand: prayerName=$prayerName, audioFilePath=$audioFilePath, isTest=$isTest")

        startAdhanPlayback(prayerName, audioFilePath, isTest)

        return START_NOT_STICKY
    }

    private fun startAdhanPlayback(prayerName: String, audioFilePath: String, isTest: Boolean) {
        // 0. Stop and release any existing player to prevent concurrent overlapping playbacks
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error cleaning up previous MediaPlayer", e)
        } finally {
            mediaPlayer = null
        }

        // 1. Release WakeLock from receiver now that service is booting/preparing
        AdhanAlarmReceiver.releaseWakeLock()

        // 2. Focus notification channel and start foreground immediately
        showForegroundNotification(prayerName)

        // Check if device is in Silent / Vibrate mode or Do Not Disturb (DND) mode
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val respectSilentDndMode = prefs.getBoolean("flutter.respect_silent_dnd_mode", false)

        val ringerMode = audioManager.ringerMode
        val isSilentOrVibrate = ringerMode == AudioManager.RINGER_MODE_SILENT || ringerMode == AudioManager.RINGER_MODE_VIBRATE
        
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val isDNDActive = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val filter = notificationManager.currentInterruptionFilter
            filter != NotificationManager.INTERRUPTION_FILTER_ALL
        } else {
            false
        }

        val shouldMute = respectSilentDndMode && (isSilentOrVibrate || isDNDActive) && !isTest

        if (shouldMute) {
            val reason = if (isSilentOrVibrate) "Ringer Mode ($ringerMode)" else "DND Mode"
            Log.d(TAG, "Device is in Silent/Vibrate/DND (respectSilentDndMode=true, reason=$reason) and this is a real alarm. Suppressing sound/vibration.")
            
            // Post a clean, clearable notification
            val channelId = "adhan_playback_channel"
            val contentIntent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("OPEN_PRAYER_TIMES", true)
            }
            val pendingContentIntent = PendingIntent.getActivity(
                this,
                2001,
                contentIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )

            val title = "حان وقت صلاة $prayerName"
            val body = "أقم الصلاة يرحمك الله"

            val vibratePattern = if (ringerMode == AudioManager.RINGER_MODE_VIBRATE && !isDNDActive) {
                longArrayOf(0, 500, 250, 500)
            } else {
                null
            }

            val cleanNotification = NotificationCompat.Builder(this, channelId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setContentIntent(pendingContentIntent)
                .setAutoCancel(true)
                .setSound(null)
                .setVibrate(vibratePattern)
                .build()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                @Suppress("DEPRECATION")
                stopForeground(true)
            }

            notificationManager.notify(NOTIFICATION_ID, cleanNotification)
            stopSelf()
            return
        }

        // 3. Request audio focus
        if (!requestFocus(isTest)) {
            Log.w(TAG, "Failed to obtain audio focus. Continuing playback anyway.")
        }

        // 4. Initialize MediaPlayer
        try {
            mediaPlayer = MediaPlayer().apply {
                val file = File(audioFilePath)
                if (audioFilePath.isNotEmpty() && file.exists() && file.length() > 0) {
                    Log.d(TAG, "Playing custom Adhan file: $audioFilePath")
                    setDataSource(audioFilePath)
                } else {
                    Log.w(TAG, "Custom file missing or empty. Playing default system notification sound.")
                    val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                    setDataSource(this@AdhanService, defaultUri)
                }

                // Set stream type dynamically depending on if it is a settings preview or a real alarm
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(if (isTest) AudioAttributes.USAGE_MEDIA else AudioAttributes.USAGE_ALARM)
                            .setContentType(if (isTest) AudioAttributes.CONTENT_TYPE_MUSIC else AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                } else {
                    @Suppress("DEPRECATION")
                    setAudioStreamType(if (isTest) AudioManager.STREAM_MUSIC else AudioManager.STREAM_ALARM)
                }

                // Explicitly set media volume to 100% of stream volume
                setVolume(1.0f, 1.0f)

                isLooping = false
                setOnCompletionListener {
                    Log.d(TAG, "MediaPlayer playback completed naturally.")
                    stopAdhan()
                }
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error: what=$what, extra=$extra")
                    stopAdhan()
                    true
                }

                prepare()
                start()
                isAdhanPlaying = true
                Log.d(TAG, "MediaPlayer started playing successfully.")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing MediaPlayer", e)
            stopAdhan()
        }
    }

    private fun showForegroundNotification(prayerName: String) {
        val channelId = "adhan_playback_channel"
        val channelName = "Adhan Playback"

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Adhan prayer notification player"
                setSound(null, null)
                enableVibration(false)
            }
            notificationManager.createNotificationChannel(channel)
        }

        // Tap notification -> MainActivity
        val contentIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("OPEN_PRAYER_TIMES", true)
            putExtra("STOP_ADHAN_ON_OPEN", true)
        }
        val pendingContentIntent = PendingIntent.getActivity(
            this,
            2001,
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        // Action stop intent
        val stopIntent = Intent(this, AdhanService::class.java).apply {
            action = "$packageName.action.STOP_ADHAN"
        }
        val pendingStopIntent = PendingIntent.getService(
            this,
            2002,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        // Action mark prayed intent
        val markIntent = Intent(this, AdhanService::class.java).apply {
            action = "$packageName.action.MARK_PRAYED_AND_STOP"
            putExtra("prayerName", prayerName)
        }
        val pendingMarkIntent = PendingIntent.getService(
            this,
            2003,
            markIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val title = "حان وقت صلاة $prayerName"
        val body = "أقم الصلاة يرحمك الله"

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setOngoing(true)
            .setContentIntent(pendingContentIntent)
            .addAction(R.drawable.ic_notification_stop, "إيقاف", pendingStopIntent)
            .addAction(R.drawable.ic_notification_check, "تمت الصلاة", pendingMarkIntent)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun requestFocus(isTest: Boolean): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(if (isTest) AudioAttributes.USAGE_MEDIA else AudioAttributes.USAGE_ALARM)
                        .setContentType(if (isTest) AudioAttributes.CONTENT_TYPE_MUSIC else AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                .setOnAudioFocusChangeListener(focusChangeListener)
                .build()
            this.focusRequest = focusRequest
            audioManager.requestAudioFocus(focusRequest) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        } else {
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                focusChangeListener,
                if (isTest) AudioManager.STREAM_MUSIC else AudioManager.STREAM_ALARM,
                AudioManager.AUDIOFOCUS_GAIN
            ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
    }

    private fun abandonFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
        } else {
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus(focusChangeListener)
        }
    }

    private fun pauseAdhan() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.pause()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error pausing MediaPlayer", e)
        }
    }

    private fun resumeAdhan() {
        try {
            mediaPlayer?.let {
                if (!it.isPlaying && isAdhanPlaying) {
                    it.start()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error resuming MediaPlayer", e)
        }
    }

    private fun stopAdhan() {
        Log.d(TAG, "stopAdhan: cleaning up and stopping service")
        
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
            }
            mediaPlayer = null
            isAdhanPlaying = false
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping/releasing MediaPlayer", e)
        }

        abandonFocus()

        if (isScreenReceiverRegistered) {
            try {
                unregisterReceiver(screenOffReceiver)
                isScreenReceiverRegistered = false
                Log.d(TAG, "Screen off receiver unregistered")
            } catch (e: Exception) {
                Log.e(TAG, "Error unregistering screen off receiver", e)
            }
        }

        AdhanAlarmReceiver.releaseWakeLock()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy")
        
        try {
            mediaPlayer?.let {
                it.release()
            }
            mediaPlayer = null
        } catch (e: Exception) {
            Log.e(TAG, "Error in MediaPlayer release inside onDestroy", e)
        }

        abandonFocus()

        if (isScreenReceiverRegistered) {
            try {
                unregisterReceiver(screenOffReceiver)
                isScreenReceiverRegistered = false
            } catch (e: Exception) {
                // Ignore
            }
        }

        AdhanAlarmReceiver.releaseWakeLock()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
