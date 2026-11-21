import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Release imzası: android/key.properties (yerelde, git'e eklenmez) veya
// CI ortam değişkenleri (ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD,
// ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD). İkisi de yoksa release derlemesi
// debug anahtarıyla imzalanır ve yalnızca test içindir.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) FileInputStream(file).use { load(it) }
}
fun signingValue(property: String, env: String): String? =
    (keystoreProperties.getProperty(property) ?: System.getenv(env))?.takeIf { it.isNotBlank() }
val releaseStoreFile = signingValue("storeFile", "ANDROID_KEYSTORE_PATH")
val hasReleaseSigning = releaseStoreFile != null &&
    signingValue("storePassword", "ANDROID_KEYSTORE_PASSWORD") != null &&
    signingValue("keyAlias", "ANDROID_KEY_ALIAS") != null &&
    signingValue("keyPassword", "ANDROID_KEY_PASSWORD") != null

android {
    namespace = "com.taktemurr.annebebek"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.taktemurr.annebebek"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = signingValue("storePassword", "ANDROID_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "ANDROID_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // Anahtar yoksa yalnızca test amaçlı debug imzası.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        )
    }
}

flutter {
    source = "../.."
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
