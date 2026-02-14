plugins {
    id("buildlogic.plugins.kmp.library")
    alias(libs.plugins.sqldelight) // to include sqlite3 in XCFramework
}

kotlin {
    android { namespace = "com.magic.core.di" }
    listOf(iosArm64(), iosSimulatorArm64()).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = "MagicDataLayer"
            export(projects.dataManagers)
            export(projects.dataModels)
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
            implementation(libs.test.kotlin)
            implementation(libs.test.koin)
        }
    }
}