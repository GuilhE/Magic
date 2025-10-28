plugins {
    id("buildlogic.plugins.kmp.library.android")
    alias(libs.plugins.google.ksp)
    alias(libs.plugins.sqldelight) //for unit test
}

android {
    namespace = "com.magic.data.managers"
}

kotlin {
    androidTarget()
    listOf(iosArm64(), iosSimulatorArm64()).forEach { iosTarget ->
        iosTarget.compilerOptions { freeCompilerArgs.add("-Xexport-kdoc") }
    }

    sourceSets {
        commonMain.dependencies {
            implementation(projects.coreNetwork)
            implementation(projects.coreDatabase)
            implementation(projects.dataModels)
            implementation(libs.kotlinx.coroutines.core)
            implementation(libs.bundles.ktor)
            implementation(libs.kmp.koin.core)
            implementation(libs.kmp.kermit)
        }
        commonTest.dependencies {
            implementation(libs.test.kotlin)
            implementation(libs.test.kmp.koin)
            implementation(libs.test.kmp.turbine)
            implementation(libs.test.kotlinx.coroutines)
            implementation(libs.ktor.client.mock)
        }
        androidMain.dependencies { implementation(libs.kmp.koin.android) }
    }
}