import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi

plugins {
    id("buildlogic.plugins.kmp.library.android")
    alias(libs.plugins.sqldelight) //to include sqlite3 in XCFramework
}

android {
    namespace = "com.magic.core.di"
}

kotlin {
    androidTarget()
    listOf(iosArm64(), iosSimulatorArm64()).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = "MagicDataLayer"
            export(projects.dataManagers)
            export(projects.dataModels)
        }
        @OptIn(ExperimentalKotlinGradlePluginApi::class)
        compilerOptions {
            freeCompilerArgs.add("-Xexport-kdoc")
        }
    }

    sourceSets {
        commonMain.dependencies {
            implementation(projects.coreNetwork)
            implementation(projects.coreDatabase)
            api(projects.dataManagers)
            api(projects.dataModels)
            implementation(libs.kmp.koin.core)
        }
    }
}