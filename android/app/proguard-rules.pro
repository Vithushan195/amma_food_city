# Amma Food City — ProGuard Rules

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Stripe
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**
-keep class com.reactnativestripesdk.** { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Crashlytics deobfuscation info
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
