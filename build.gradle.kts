plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.android.multiplatform.library) apply false
    alias(libs.plugins.kotlin.multiplatform) apply false
    alias(libs.plugins.compose.multiplatform) apply false
    alias(libs.plugins.compose.compiler) apply false
    alias(libs.plugins.sqldelight) apply false
    alias(libs.plugins.ktlint) apply false
}

// Xcode exposes CONFIGURATION (Debug/Release) to build phases and scheme pre-actions.
val xcodeConfiguration = providers.environmentVariable("CONFIGURATION").orElse("Debug").get()
require(xcodeConfiguration in listOf("Debug", "Release")) { "Unsupported CONFIGURATION: $xcodeConfiguration" }

// SwiftPM dependency paths can't vary per configuration, so the package is synced to a fixed folder.
val syncSwiftPackageForXcode = tasks.register<Sync>("syncSwiftPackageForXcode") {
    description = "Syncs the exported Swift package for the current Xcode CONFIGURATION into core-di/SwiftPackage/Current"
    val swiftPackages = layout.projectDirectory.dir("core-di/SwiftPackage")
    dependsOn(":core-di:export${xcodeConfiguration}SwiftPackage")
    from(swiftPackages.dir(xcodeConfiguration))
    into(swiftPackages.dir("Current"))
}

tasks.register("exportFrameworkForXcode") {
    description = "Exports the core-di Swift package for Xcode (Debug/Release from CONFIGURATION, defaults to Debug)"
    dependsOn(syncSwiftPackageForXcode)
}
