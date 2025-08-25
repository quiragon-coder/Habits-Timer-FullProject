// android/settings.gradle.kts
@file:Suppress("UnstableApiUsage")

import java.util.Properties
import java.io.File
import java.io.FileInputStream

rootProject.name = "habits_timer"
include(":app")

// --- Lire flutter.sdk depuis local.properties ---
val localProps = File(rootDir, "local.properties")
val props = Properties()
if (localProps.exists()) {
    FileInputStream(localProps).use { fis -> props.load(fis) }
}
val flutterSdkPath = props.getProperty("flutter.sdk")
    ?: error("`flutter.sdk` manquant dans local.properties. Lance `flutter doctor` pour (re)générer.")

// --- Charger l’integration des plugins Flutter (v2 embedding) ---
apply(from = File(flutterSdkPath, "packages/flutter_tools/gradle/app_plugin_loader.gradle"))

// --- Repos plugins & dépendances ---
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
