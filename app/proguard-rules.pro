# Ez Dozit ProGuard Rules

# Room - keep entity classes and DAOs
-keep class org.ezdozit.app.data.** { *; }
-dontwarn androidx.room.**

# MapLibre
-keep class org.maplibre.android.** { *; }
-dontwarn org.maplibre.android.**

# KotlinX Serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** { *** Companion; }
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}
-keep,includedescriptorclasses class org.ezdozit.app.**$$serializer { *; }
-keepclassmembers class org.ezdozit.app.** {
    *** Companion;
}
-keepclasseswithmembers class org.ezdozit.app.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep line numbers for crash debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
