// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "KMPBridge",
            targets: ["KMPBridge"]
        ),
        .library(
            name: "CardRepository",
            targets: ["CardRepository"]
        ),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/rickclephas/KMP-NativeCoroutines.git", exact: "1.0.0-ALPHA-45-spm-async"),
    ],
    targets: [
        .target(
            name: "KMPBridge",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
            ]
        ),
        .target(
            name: "CardRepository",
            dependencies: [
                "KMPBridge",
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                .product(name: "KMPNativeCoroutinesAsync", package: "KMP-NativeCoroutines"),
            ]
        ),
    ]
)
