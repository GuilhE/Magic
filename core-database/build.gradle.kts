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
            implementation(libs.kmp.sqldelight.coroutines.extensions)
            implementation(libs.kmp.koin.core)
        }
        commonTest.dependencies {
            implementation(libs.test.kotlin)
            implementation(libs.test.kmp.koin)
            implementation(libs.test.kmp.turbine)
            implementation(libs.test.kotlinx.coroutines)
        }
        androidMain.dependencies {
            implementation(libs.kmp.sqldelight.android.driver)
            implementation(libs.kmp.sqldelight.driver)
        }
        iosMain.dependencies { implementation(libs.kmp.sqldelight.ios.driver) }
    }
}

sqldelight {
    databases {
        create("MagicDatabase") {
            packageName.set("com.magic.core.database")
        }
    }
}