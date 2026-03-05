# Agora SDK ProGuard Rules
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# Keep desugar runtime classes
-keep class com.google.devtools.build.android.desugar.runtime.** { *; }

# Keep all classes referenced by Agora
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
