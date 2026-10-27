@file:OptIn(ExperimentalSwiftExportDsl::class)

import org.jetbrains.kotlin.gradle.swiftexport.ExperimentalSwiftExportDsl

plugins {
    id("buildlogic.plugins.kmp.library")
}

kotlin {
    android { namespace = "com.magic.core.di" }
    iosArm64()
    iosSimulatorArm64()

    export {
		swift {
			moduleName = "MagicDataLayer"
			rootPackage = "com.magic.core.di"
			swiftPackageIntegration {
				configure(projects.dataManagers) {
					moduleName = "MagicDataManagers"
					rootPackage = "com.magic.data.managers"
				}
				configure(projects.dataModels) {
					moduleName = "MagicDataModels"
					rootPackage = "com.magic.data.models"
				}
			}
		}
    }

    sourceSets {
        commonMain.dependencies {
			api(projects.dataManagers)
			api(projects.dataModels)
			implementation(projects.coreNetwork)
			implementation(projects.coreDatabase)
            implementation(libs.koin.core)
        }
		commonTest.dependencies {
			implementation(libs.test.koin)
		}
    }
}
