// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "DI",
            targets: ["DI"]
        ),
        .library(
            name: "FactoryProtocols",
            targets: ["FactoryProtocols"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", exact: "2.9.1"),
    ],
    targets: [
        .target(
            name: "DI",
            dependencies: [
                .product(name: "Swinject", package: "Swinject"),
            ]
        ),
        .target(
            name: "FactoryProtocols",
            dependencies: []
        ),
    ]
)
