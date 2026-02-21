plugins {
    id("buildlogic.plugins.kmp.library")
    alias(libs.plugins.kotlinx.serialization)
}

kotlin {
    android { namespace = "com.magic.data.models" }
    iosArm64()
    iosSimulatorArm64()

    sourceSets {
        commonMain.dependencies { implementation(libs.kotlinx.serialization) }
    }
}