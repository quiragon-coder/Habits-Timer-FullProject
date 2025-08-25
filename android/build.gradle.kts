// Root build.gradle.kts for a Flutter Android project (Kotlin DSL)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    // No classpath deps needed here when using the Flutter plugin loader in settings.gradle.kts
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
