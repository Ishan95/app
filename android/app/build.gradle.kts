import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "lk.transfer.multiservice"
    // Updated to 35 to support your new plugins
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "lk.transfer.multiservice"
        minSdk = flutter.minSdkVersion
        // Updated to 35 to match compileSdk
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

//     signingConfigs {
//     create("release") {
//         storeFile = file(keystoreProperties["storeFile"] as String)
//         storePassword = keystoreProperties["storePassword"] as String
//         keyAlias = keystoreProperties["keyAlias"] as String
//         keyPassword = keystoreProperties["keyPassword"] as String
//     }
// }
    
//     buildTypes {
//     release {
//         signingConfig = signingConfigs.getByName("release")
//     }
// }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    // Updated to 2.1.4 as requested by the error log
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}