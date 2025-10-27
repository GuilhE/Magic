@file:OptIn(ExperimentalSwiftExportDsl::class)

import org.jetbrains.kotlin.gradle.swiftexport.ExperimentalSwiftExportDsl

plugins {
    id("buildlogic.plugins.kmp.library.android")
}

android {
    namespace = "com.magic.core.di"
}

kotlin {
    androidTarget()
    listOf(iosArm64(), iosSimulatorArm64()).forEach { iosTarget ->
        iosTarget.compilerOptions { freeCompilerArgs.add("-Xexport-kdoc") }
    }

    swiftExport {
        moduleName = "MagicDI"
        //https://youtrack.jetbrains.com/issue/KT-81270/K-N-Build-fails-when-exposing-suspend-functions#focus=Comments-27-12735527.0-0
        //flattenPackage = "com.magic.core.di"
        configure { settings.put("enableCoroutinesSupport", "true") }
        export(projects.dataManagers) { moduleName = "MagicDataManagers" }
        export(projects.dataModels) { moduleName = "MagicDataModels" }
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