plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Properties
import java.io.FileInputStream
import java.io.File

// Load keystore properties
val keystorePropertiesFile = file("${rootProject.projectDir}/key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("WARNING: key.properties not found at: ${keystorePropertiesFile.absolutePath}")
}

android {
    namespace = "com.asentyx.fuelmate"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // Updated application ID for Play Store
        applicationId = "com.asentyx.fuelmate"
        minSdk = flutter.minSdkVersion  // Firebase and Location services require minimum SDK 21
        targetSdk = 36  // Latest Android 15
        
        // Version is read from pubspec.yaml by Flutter
        // Format: version: 1.0.0+3 (versionName=1.0.0, versionCode=3)
        // Flutter automatically syncs these values, but we set defaults here
        versionCode = 3  // Increment this for each Play Store upload
        versionName = "1.0.0"
        
        multiDexEnabled = true  // Enable MultiDex for Firebase
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val keyAliasProp = keystoreProperties.getProperty("keyAlias")?.trim()
                val keyPasswordProp = keystoreProperties.getProperty("keyPassword")?.trim()
                val storeFilePath = keystoreProperties.getProperty("storeFile")?.trim()
                val storePasswordProp = keystoreProperties.getProperty("storePassword")?.trim()

                if (
                    keyAliasProp.isNullOrBlank() ||
                    keyPasswordProp.isNullOrBlank() ||
                    storeFilePath.isNullOrBlank() ||
                    storePasswordProp.isNullOrBlank()
                ) {
                    throw GradleException("❌ Missing keystore properties. Check key.properties file.")
                }

                val keystoreFile = if (File(storeFilePath).isAbsolute) {
                    File(storeFilePath)
                } else {
                    File(keystorePropertiesFile.parentFile, storeFilePath)
                }

                if (!keystoreFile.exists()) {
                    throw GradleException("❌ Keystore file not found: ${keystoreFile.absolutePath}")
                }

                keyAlias = keyAliasProp
                keyPassword = keyPasswordProp
                storeFile = keystoreFile
                storePassword = storePasswordProp
            }
        }
    }

    buildTypes {
        release {
            // Enable code shrinking, obfuscation, and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Use release signing if key.properties exists, otherwise use debug
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            
            // Disable native library symbol stripping to avoid warnings
            // Debug symbols are handled via --split-debug-info flag
            ndk {
                debugSymbolLevel = "NONE"
            }
        }
        
        debug {
            // Use same package name as release for Firebase compatibility
            // Explicitly set to empty to prevent .debug suffix
            applicationIdSuffix = ""
            versionNameSuffix = "-debug"
        }
    }
    
    // Bundle configuration for AAB
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring for flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
