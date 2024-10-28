// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "CardListPresentation",
            targets: ["CardListPresentation"]
        ),
        .library(
            name: "CardDeckPresentation",
            targets: ["CardDeckPresentation"]
        ),
        .library(
            name: "CardUIModels",
            targets: ["CardUIModels"]
        ),
    ],
    dependencies: [
        .package(path: "../Domain"),
    ],
    targets: [
        .target(
            name: "CardListPresentation",
            dependencies: [
                "CardUIModels",
                .product(name: "DomainProtocols", package: "Domain"),
                .product(name: "CardDomain", package: "Domain"),
            ]
        ),
        .target(
            name: "CardDeckPresentation",
            dependencies: [
                "CardUIModels",
                .product(name: "DomainProtocols", package: "Domain"),
                .product(name: "CardDomain", package: "Domain"),
            ]
        ),
        .target(
            name: "CardUIModels",
            dependencies: [
                .product(name: "DomainProtocols", package: "Domain"),
            ]
        ),
    ]
)
