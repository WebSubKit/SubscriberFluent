// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SubscriberFluent",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SubscriberFluent",
            targets: ["SubscriberFluent"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.47.2"),
        .package(url: "https://github.com/WebSubKit/SubscriberKit.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SubscriberFluent",
            dependencies: [
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "SubscriberKit", package: "SubscriberKit")
            ]
        )
    ]
)
