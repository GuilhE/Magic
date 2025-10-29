@file:OptIn(ExperimentalSwiftExportDsl::class)

import org.jetbrains.kotlin.gradle.plugin.mpp.apple.swiftexport.SWIFT_EXPORT_COROUTINES_SUPPORT_TURNED_ON
import org.jetbrains.kotlin.gradle.swiftexport.ExperimentalSwiftExportDsl

plugins {
    id("buildlogic.plugins.kmp.library")
}

kotlin {
    android { namespace = "com.magic.core.di" }
    listOf(iosArm64(), iosSimulatorArm64()).forEach { iosTarget ->
        iosTarget.compilerOptions { freeCompilerArgs.add("-Xexport-kdoc") }
    }

    swiftExport {
        moduleName = "MagicDI"
        flattenPackage = "com.magic.core.di"
        configure { settings.put(SWIFT_EXPORT_COROUTINES_SUPPORT_TURNED_ON, "true") }
        export(projects.dataManagers) {
            moduleName = "MagicDataManagers"
            flattenPackage = "com.magic.data.managers"
        }
        export(projects.dataModels) {
            moduleName = "MagicDataModels"
            flattenPackage = "com.magic.data.models"
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