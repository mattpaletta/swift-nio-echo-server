// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let targets: [PackageDescription.Target] = [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "basic-client",
            dependencies: ["NIOHTTP1"]),
        .target(
            name: "middle-server",
            dependencies: ["NIOHTTP1"]),
        .target(
            name: "echo-server",
            dependencies: ["NIOHTTP1"]),
]

let package = Package(
    name: "swift-nio-echo-server",
    products: [
        .executable(name: "basic-client", targets: ["basic-client"]),
        .executable(name: "middle-server", targets: ["middle-server"]),
        .executable(name: "echo-server", targets: ["echo-server"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.5.1"),
        ],
    targets: targets
)
