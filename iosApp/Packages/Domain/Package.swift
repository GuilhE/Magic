// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "DomainProtocols",
            targets: ["DomainProtocols"]
        ),
        .library(
            name: "CardDomain",
            targets: ["CardDomain"]
        ),
    ],
    targets: [
        .target(
            name: "DomainProtocols",
            dependencies: []
        ),
        .target(
            name: "CardDomain",
            dependencies: ["DomainProtocols"]
        ),
    ]
)
