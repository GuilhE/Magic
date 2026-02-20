@file:Suppress("UnstableApiUsage")

pluginManagement {
    includeBuild("build-logic")
    repositories {
        gradlePluginPortal()
        google()
        mavenLocal()
        mavenCentral()
        maven("https://redirector.kotlinlang.org/maven/dev")
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenLocal()
        mavenCentral()
        maven("https://redirector.kotlinlang.org/maven/dev")
    }
}

enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

rootProject.name = "Magic"
include(":androidApp")
include(":core-di")
include(":core-network")
include(":core-database")
include(":data-managers")
include(":data-models")