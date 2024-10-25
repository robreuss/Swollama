// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swollama",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Swollama",
            targets: ["Swollama"]),
        .executable(
            name: "SwollamaCLI",
            targets: ["SwollamaCLI"])
    ],
    targets: [
        .target(
            name: "Swollama"),
        .executableTarget(
            name: "SwollamaCLI",
            dependencies: ["Swollama"]),
        .testTarget(
            name: "SwollamaTests",
            dependencies: ["Swollama"]
        ),
    ]
)
