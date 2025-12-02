plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Плагины для gms_services:
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.zaim.ru.good.cash"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.zaim.ru.good.cash"
        minSdk = 29
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("id_557.keystore")
            storePassword = "mypass"
            keyAlias = "com.zaim.ru.good.cash"
            keyPassword = "mypass"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            signingConfig = signingConfigs.getByName("release")
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Зависимости для gms_services:
    implementation("com.google.android.gms:play-services-location:21.3.0")
    implementation("com.android.installreferrer:installreferrer:2.2")
}
