// [REVISED & CLEAN CODE - android/app/build.gradle.kts v5.6]

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Standard Flutter plugin setup
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Firebase support ✅
}

android {
    namespace = "com.example.kutty_guru_ai"
    
    // 🚨 PATCH: Updated to SDK 36 as required by your plugins
    compileSdk = 36 

    // 🚨 PATCH: Using the exact NDK version your terminal requested
    ndkVersion = "28.2.13676358" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.njtech.namma_guru_ai"
        minSdk = flutter.minSdkVersion
        
        // 🚨 targetSdk matched to compileSdk
        targetSdk = 36
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        externalNativeBuild {
            cmake {
                version = "3.22.1"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.4"))
    implementation("com.google.firebase:firebase-analytics-ktx")
}
