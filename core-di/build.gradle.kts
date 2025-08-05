import org.jetbrains.kotlin.gradle.swiftexport.ExperimentalSwiftExportDsl

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
        compilerOptions {
            freeCompilerArgs.add("-Xexport-kdoc")
        }
    }

    @OptIn(ExperimentalSwiftExportDsl::class)
    swiftExport {
        moduleName = "MagicDataLayer"
        flattenPackage = "com.magic"

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
            api(projects.dataManagers)
            api(projects.dataModels)
            implementation(projects.coreNetwork)
            implementation(projects.coreDatabase)
            implementation(libs.kmp.koin.core)
        }
    }
}