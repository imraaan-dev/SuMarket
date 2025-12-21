plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")

    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    // Google Services plugin (required for Firebase to read google-services.json)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.su_fridges"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.su_fridges"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Firebase BoM (keeps Firebase libraries compatible)
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))

    // Firebase Analytics (example)
    implementation("com.google.firebase:firebase-analytics")

    // Add other Firebase SDKs you want (NO versions when using BoM), e.g.:
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-messaging")
}

flutter {
    source = "../.."
}
