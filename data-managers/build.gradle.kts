plugins {
    id("buildlogic.plugins.kmp.library")
    alias(libs.plugins.google.ksp)
    alias(libs.plugins.nativecoroutines)
    alias(libs.plugins.sqldelight) //for unit test
}

kotlin {
    android { namespace = "com.magic.data.managers" }
    iosArm64()
    iosSimulatorArm64()

    sourceSets {
        commonMain.dependencies {
            implementation(projects.coreNetwork)
            implementation(projects.coreDatabase)
            implementation(projects.dataModels)
            implementation(libs.kotlinx.coroutines.core)
            implementation(libs.bundles.ktor)
            implementation(libs.koin.core)
            implementation(libs.kermit)
        }
        commonTest.dependencies {
            implementation(libs.test.kotlin)
            implementation(libs.test.koin)
            implementation(libs.test.turbine)
            implementation(libs.test.kotlinx.coroutines)
            implementation(libs.ktor.client.mock)
        }
        androidMain.dependencies { implementation(libs.koin.android) }
    }
}