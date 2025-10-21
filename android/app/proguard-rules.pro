# === KEEP ML KIT CLASSES ===
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# === KEEP FLUTTER CLASSES ===
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# === KEEP ANDROIDX CLASSES ===
-keep class androidx.** { *; }
-dontwarn androidx.**

# === AVOID STRIPPING COMMON LIBRARIES ===
-keep class kotlin.** { *; }
-dontwarn kotlin.**
