// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Áp dụng plugin google-services
}

android {
    namespace = "com.example.relumen" // Giữ namespace hiện tại của bạn
    compileSdk = flutter.compileSdkVersion

    // >>> SỬA ĐỔI 1: CẬP NHẬT NDK VERSION <<<
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.relumen" // Giữ applicationId hiện tại của bạn

        // >>> SỬA ĐỔI 2: TĂNG MINSDKVERSION <<<
        minSdk = 23 // Thay vì flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
  implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
  implementation("com.google.firebase:firebase-analytics")
  // Các dependencies khác (nếu có)
}