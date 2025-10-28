// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v26)],
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
                .product(name: "DomainUseCases", package: "Domain")
            ]
        ),
    ]
)
