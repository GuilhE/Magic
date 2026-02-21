// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [.iOS(.v26)],
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
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "8.5.0"),
    ],
    targets: [
        .target(
            name: "CardListPresentation",
            dependencies: [
                "CardUIModels",
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
            ]
        ),
        .target(
            name: "CardDeckPresentation",
            dependencies: [
                "CardUIModels",
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                .product(name: "Kingfisher", package: "Kingfisher"),
            ]
        ),
        .target(
            name: "CardUIModels",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
            ]
        ),
    ]
)
