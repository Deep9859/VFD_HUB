# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Suppress warnings for generated plugin registrant
-dontwarn io.flutter.plugins.GeneratedPluginRegistrant

# Google Play Core (deferred components) - suppress missing class errors
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
