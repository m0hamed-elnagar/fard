# Fard App - Optimized ProGuard Rules for Release Build

# ===========================
# GENERAL RULES
# ===========================
-keepattributes *Annotation*,Signature,EnclosingMethod,InnerClasses
-keepattributes SourceFile,LineNumberTable

# Keep native methods
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# ===========================
# APP ENTRY POINTS & RECEIVERS
# ===========================
-keep class com.khwarizmi.fard.FardApplication { *; }
-keep class com.khwarizmi.fard.MainActivity { *; }
-keep class com.khwarizmi.fard.PrayerWidgetReceiver
-keep class com.khwarizmi.fard.NextPrayerCountdownWidgetReceiver
-keep class com.khwarizmi.fard.TimeChangedReceiver
-keep class com.khwarizmi.fard.BootReceiver
-keep class com.khwarizmi.fard.ExactAlarmPermissionReceiver
-keep class com.khwarizmi.fard.prayer.AdhanAlarmReceiver
-keep class com.khwarizmi.fard.prayer.AdhanService { *; }

# ===========================
# GLANCE WIDGETS
# ===========================
# Keep ActionCallback for Glance widgets (dynamically loaded)
-keep public class * extends androidx.glance.appwidget.action.ActionCallback

# ===========================
# WORKMANAGER WORKERS
# ===========================
# Custom workers (like WidgetUpdateWorker) are instantiated via reflection.
-keep public class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# ===========================
# THIRD-PARTY FLUTTER PLUGINS
# ===========================
# Only keep the specific receivers required by these plugins, rather than their entire libraries.
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
-keep class com.ryanheise.audioservice.MediaButtonReceiver

# ===========================
# CRASHLYTICS & FIREBASE
# ===========================
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# ===========================
# SUPPRESS WARNINGS
# ===========================
-dontnote
-dontwarn javax.**
-dontwarn org.xmlpull.v1.**
-dontwarn com.google.android.**
-dontwarn io.flutter.**
