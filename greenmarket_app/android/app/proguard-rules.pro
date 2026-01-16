# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Notification
-keep class com.dexterous.** { *; }

# Package Info Plus
-keep class io.flutter.plugins.packageinfo.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# HTTP
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Gson (agar JSON parsing uchun ishlatilsa)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Umumiy qoidalar
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Play Core (Flutter deferred components uchun)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
