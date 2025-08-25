plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

val flutterVersionCode: Int = (project.findProperty("flutter.versionCode") as String?)?.toIntOrNull() ?: 1
val flutterVersionName: String = (project.findProperty("flutter.versionName") as String?) ?: "1.0"

android {
    namespace = "com.habitstimer.habits_timer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.habitstimer.habits_timer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Remplace par ta config de signature (keystore) pour la production
            signingConfig = signingConfigs.debug
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            // config debug si besoin
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    // Répertoire de la source Flutter relative au module android/app
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
}
