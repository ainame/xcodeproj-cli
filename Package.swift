// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcodeproj-cli",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "xcodeproj", targets: ["xcodeproj-cli"])
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "9.4.3"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "xcodeproj-cli",
            dependencies: [
                .product(name: "XcodeProj", package: "XcodeProj"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)
