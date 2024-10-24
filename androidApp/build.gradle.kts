plugins {
    id("buildlogic.plugins.application")
}

android {
    namespace = "com.magic.app.android"
    defaultConfig {
        applicationId = "com.magic.app.android"
        versionCode = 1
        versionName = "1.0"

        resValue("string", "app_name_label", "Magic")
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }

        getByName("debug") {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    implementation(projects.coreDi)
    implementation(projects.dataModels)
    implementation(projects.dataManagers)
    implementation(libs.androidx.lifecycle.runtime)
    implementation(libs.android.material)
    implementation(libs.kmp.koin.android)
    implementation(libs.kmp.koin.androidx.compose)
}