# Flutter Local Notifications Proguard Rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.android.gms.internal.firebase_messaging.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Prevent obfuscation of timezone data if necessary
-keep class com.timezone.** { *; }
