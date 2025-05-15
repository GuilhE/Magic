// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "DataExtensions",
            targets: ["DataExtensions"]
        ),
        .library(
            name: "CardData",
            targets: ["CardData"]
        ),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/rickclephas/KMP-NativeCoroutines.git", exact: "1.0.0-ALPHA-43-spm-async"),
    ],
    targets: [
        .target(
            name: "DataExtensions",
            dependencies: [
                .product(name: "DomainProtocols", package: "Domain"),
            ]
        ),
        .target(
            name: "CardData",
            dependencies: [
                "DataExtensions",
                .product(name: "DomainProtocols", package: "Domain"),
                .product(name: "CardDomain", package: "Domain"),
                .product(name: "KMPNativeCoroutinesAsync", package: "KMP-NativeCoroutines"),
            ]
        ),
    ]
)
