// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "DomainModels",
            targets: ["DomainModels"]
        ),
        .library(
            name: "DomainUseCases",
            targets: ["DomainUseCases"]
        ),
    ],
    targets: [
        .target(
            name: "DomainModels",
            dependencies: []
        ),
        .target(
            name: "DomainUseCases",
            dependencies: ["DomainModels"]
        ),
    ]
)
