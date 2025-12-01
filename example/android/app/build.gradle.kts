plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Плагин для hms_services:
    id("com.huawei.agconnect")
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
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
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
    // Зависимость для hms_services:
    implementation("com.android.installreferrer:installreferrer:2.2")
}
