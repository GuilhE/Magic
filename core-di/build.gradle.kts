@file:OptIn(ExperimentalSwiftExportDsl::class)

import org.jetbrains.kotlin.gradle.swiftexport.ExperimentalSwiftExportDsl

plugins {
    id("buildlogic.plugins.kmp.library")
}

kotlin {
    android { namespace = "com.magic.core.di" }
    iosArm64()
    iosSimulatorArm64()

    swiftExport {
        moduleName = "MagicDataLayer"
        flattenPackage = "com.magic.core.di"
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
            implementation(libs.koin.core)
        }
		commonTest.dependencies {
			implementation(libs.test.koin)
		}
    }
}
