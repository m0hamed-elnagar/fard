# Fard App - ProGuard Rules for Release Build
# This file prevents critical classes from being obfuscated or removed during release builds

# ===========================
# GENERAL RULES
# ===========================

# Keep attributes
-keepattributes *Annotation*,Signature,EnclosingMethod,InnerClasses
-keepattributes SourceFile,LineNumberTable

# Keep public classes
-keep public class * { public protected *; }

# Keep native methods
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# ===========================
# HIVE CE DATABASE
# ===========================

# Keep all Hive CE adapters and related classes
-keep class * extends com.hivewallet.hive.ce.HiveAdapter
-keep class * implements com.hivewallet.hive.ce.TypeAdapter
-keep class * extends com.hivewallet.hive.ce.HiveEnum
-keep class * extends com.hivewallet.hive.ce.HiveObject

# Keep TypeAdapter generation
-keep class com.hivewallet.hive.ce.** { *; }
-dontwarn com.hivewallet.hive.ce.**

# Keep all entity classes (prevent field obfuscation)
-keep class com.qada.fard.features.prayer_tracking.data.** { *; }
-keep class com.qada.fard.features.quran.data.datasources.local.entities.** { *; }
-keep class com.qada.fard.features.azker.data.** { *; }
-keep class com.qada.fard.features.tasbih.data.** { *; }

# Keep Hive registrar
-keep class com.qada.fard.HiveRegistrar
-keep class com.qada.fard.hive_registrar

# ===========================
# BLOC / STATE MANAGEMENT
# ===========================

# Keep BLoC classes
-keep class * extends bloc.BlocBase { *; }
-keep class * extends bloc.Bloc { *; }
-keep class * extends bloc.Cubit { *; }

# Keep flutter_bloc classes
-keep class com.brianegan.bloc.** { *; }
-keep class * extends com.brianegan.bloc.Bloc { *; }
-keep class * extends com.brianegan.bloc.Cubit { *; }

# Keep Freezed generated classes
-keep class * implements org.freezed.Union
-keep class * extends org.freezed.Union
-keep class * extends com.qada.fard.**_FreezedUnion
-keep class com.qada.fard.**$* { *; }

# Keep Equatable classes
-keep class * extends equatable.Equatable { *; }

# Keep injectable/GetIt
-keep class * extends injectable.Injectable
-keep class * implements org.koin.core.module.Module
-keep class org.koin.** { *; }
-dontwarn org.koin.**

# ===========================
# FLUTTER LOCAL NOTIFICATIONS
# ===========================

# Keep notification receivers
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver

# Keep notification models
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# ===========================
# AUDIO SERVICE (just_audio)
# ===========================

# Keep audio service
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.audioservice.AudioService
-keep class com.ryanheise.audioservice.MediaButtonReceiver

# Keep just_audio
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.just_audio.**

# ===========================
# WORKMANAGER (Background Tasks)
# ===========================

# Keep workmanager classes
-keep class be.tramckrijte.workmanager.** { *; }
-keep class be.tramckrijte.workmanager.WorkmanagerPlugin
-keep class be.tramckrijte.workmanager.BackgroundWorker

# Keep background service implementation
-keep class com.qada.fard.core.services.background.** { *; }

# ===========================
# FLUTTER BINDINGS
# ===========================

# Keep Flutter embedding
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep Flutter application
-keep class com.qada.fard.FardApplication

# Keep MainActivity
-keep class com.qada.fard.MainActivity

# Keep Widget Receivers
-keep class com.qada.fard.PrayerWidgetReceiver
-keep class com.qada.fard.NextPrayerCountdownWidgetReceiver
-keep class com.qada.fard.TimeChangedReceiver
-keep class com.qada.fard.BootReceiver

# ===========================
# GLANCE WIDGETS
# ===========================

# Keep Glance widget classes
-keep class androidx.glance.** { *; }
-dontwarn androidx.glance.**

# ===========================
# ADHAN LIBRARY
# ===========================

# Keep adhan
-keep class com.batoulapps.adhan.** { *; }
-dontwarn com.batoulapps.adhan.**

# ===========================
# JSON SERIALIZATION
# ===========================

# Keep JSON serializable classes
-keep class * implements json_annotation.JsonSerializable
-keep class * extends json_annotation.JsonConverter
-keep class json_annotation.** { *; }
-dontwarn json_annotation.**

# Keep GSON if used
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# ===========================
# SHARED PREFERENCES
# ===========================

# Keep shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences

# ===========================
# LOCATION SERVICES
# ===========================

# Keep geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator

# Keep geocoding
-keep class com.baseflow.geocoding.** { *; }
-dontwarn com.baseflow.geocoding

# ===========================
# HOME WIDGET
# ===========================

# Keep home_widget plugin
-keep class es.antonbmpz.home_widget.** { *; }
-keep class com.abdelhakim.home_widget.** { *; }
-dontwarn es.antonbmpz.home_widget

# ===========================
# PACKAGE INFO
# ===========================

# Keep package_info_plus
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }
-dontwarn dev.fluttercommunity.plus.packageinfo

# ===========================
# KEEP ALL MODEL/ENTITY CLASSES
# ===========================

# Keep all data classes in domain layer
-keep class com.qada.fard.features.**.domain.** { *; }

# Keep all data models in data layer
-keep class com.qada.fard.features.**.data.models.** { *; }
-keep class com.qada.fard.features.**.data.entities.** { *; }
-keep class com.qada.fard.core.models.** { *; }
-keep class com.qada.fard.core.domain.** { *; }

# ===========================
# KEEP ENUMS
# ===========================

-keepclassmembers,allowoptimization,allowshrinking enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ===========================
# KEEP CUSTOM VIEW CLASSES
# ===========================

-keepnames class * extends android.view.View
-keepnames class * extends android.app.Activity
-keepnames class * extends android.app.Application
-keepnames class * extends android.app.Service
-keepnames class * extends android.content.BroadcastReceiver
-keepnames class * extends android.content.ContentProvider

# ===========================
# SUPPRESS WARNINGS
# ===========================

# Suppress common warnings
-dontnote
-dontwarn javax.**
-dontwarn org.xmlpull.v1.**
-dontwarn com.google.android.**
