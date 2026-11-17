@file:OptIn(ExperimentalSwiftExportDsl::class)

import org.jetbrains.kotlin.gradle.swiftexport.ExperimentalSwiftExportDsl

plugins {
    id("buildlogic.plugins.kmp.library")
}

private val frameworkName = "MagicDataLayer"

kotlin {
    android { namespace = "com.magic.core.di" }
    iosArm64()
    iosSimulatorArm64()

    export {
		swift {
			moduleName = frameworkName
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

// Xcode exposes CONFIGURATION (Debug/Release) to build phases and scheme pre-actions.
private val xcodeConfiguration = providers.environmentVariable("CONFIGURATION").orElse("Debug").get()
require(xcodeConfiguration in listOf("Debug", "Release")) { "Unsupported CONFIGURATION: $xcodeConfiguration" }

// SwiftPM dependency paths can't vary per configuration, so the package is synced to a fixed folder.
private val syncSwiftPackageForXcode =
	tasks.register<Sync>("syncSwiftPackageForXcode") {
		description = "Syncs the exported Swift package for the current Xcode CONFIGURATION into SwiftPackage/$frameworkName"
		val swiftPackages = layout.projectDirectory.dir("SwiftPackage")
		dependsOn("export${xcodeConfiguration}SwiftPackage")
		from(swiftPackages.dir(xcodeConfiguration))
		into(swiftPackages.dir(frameworkName))
	}

tasks.register("exportFrameworkForXcode") {
	description = "Exports the Swift package for Xcode (Debug/Release from CONFIGURATION, defaults to Debug)"
	dependsOn(syncSwiftPackageForXcode)
}
