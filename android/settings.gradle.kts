import java.util.Properties
import java.io.FileInputStream

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // Load flutter sdk path from local.properties
    val props = Properties()
    val localProps = File(rootDir, "local.properties")
    if (localProps.exists()) {
        FileInputStream(localProps).use { props.load(it) }
    }
    val flutterSdkPath = props.getProperty("flutter.sdk")
        ?: throw GradleException("flutter.sdk not set in local.properties")

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Gradle plugin versions for Android and Kotlin; must match your installed toolchain
    id("com.android.application") version "8.3.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

include(":app")
