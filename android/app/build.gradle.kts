import java.io.FileInputStream
import java.util.Properties

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

println("KEY FILE PATH: ${keystorePropertiesFile.absolutePath}")
println("KEY EXISTS: ${keystorePropertiesFile.exists()}")
println("KEY PROPS: $keystoreProperties")

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.IAM.IAM_Ecomm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        applicationId = "com.IAM.IAM_Ecomm"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {

            // ONLY apply signing if key.properties exists
            if (keystorePropertiesFile.exists()) {

                val keyAliasValue = keystoreProperties.getProperty("keyAlias")
                val keyPasswordValue = keystoreProperties.getProperty("keyPassword")
                val storeFileValue = keystoreProperties.getProperty("storeFile")
                val storePasswordValue = keystoreProperties.getProperty("storePassword")

                if (
                    keyAliasValue != null &&
                    keyPasswordValue != null &&
                    storeFileValue != null &&
                    storePasswordValue != null
                ) {
                    keyAlias = keyAliasValue
                    keyPassword = keyPasswordValue
                    storeFile = file(storeFileValue)
                    storePassword = storePasswordValue

                    println("Release signing ENABLED")
                } else {
                    println("Release signing DISABLED - missing properties")
                }

            } else {
                println("Release signing DISABLED - key.properties not found")
            }
        }
    }

    buildTypes {

        getByName("debug") {
            // Uses default Android debug signing automatically
        }

        getByName("release") {

            // Only use release signing if config exists
            if (keystorePropertiesFile.exists()) {

                val hasAllKeys =
                    keystoreProperties.getProperty("keyAlias") != null &&
                    keystoreProperties.getProperty("keyPassword") != null &&
                    keystoreProperties.getProperty("storeFile") != null &&
                    keystoreProperties.getProperty("storePassword") != null

                if (hasAllKeys) {
                    signingConfig = signingConfigs.getByName("release")
                }
            }

            isMinifyEnabled = true
            isShrinkResources = true

            // Optional:
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}

println("KEYSTORE FILE EXISTS: ${keystorePropertiesFile.exists()}")
println("KEYSTORE CONTENT: $keystoreProperties")