plugins {
    id("buildlogic.plugins.kmp.library")
    alias(libs.plugins.sqldelight)
}

kotlin {
    android { namespace = "com.magic.core.database" }
    iosArm64()
    iosSimulatorArm64()

    sourceSets {
        commonMain.dependencies {
            implementation(libs.kotlinx.coroutines.core)
            implementation(libs.sqldelight.coroutines.extensions)
            implementation(libs.koin.core)
        }
        commonTest.dependencies {
            implementation(libs.test.kotlin)
            implementation(libs.test.koin)
            implementation(libs.test.turbine)
            implementation(libs.test.kotlinx.coroutines)
        }
        androidMain.dependencies {
            implementation(libs.sqldelight.android.driver)
            implementation(libs.sqldelight.driver)
        }
        iosMain.dependencies { implementation(libs.sqldelight.ios.driver) }
    }
}

sqldelight {
    databases {
        create("MagicDatabase") {
            packageName.set("com.magic.core.database")
        }
    }
}