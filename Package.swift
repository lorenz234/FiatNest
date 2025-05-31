// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FiatNest",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FiatNest",
            targets: ["FiatNest"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.8.3")
    ],
    targets: [
        .target(
            name: "FiatNest",
            dependencies: [
                .product(name: "web3", package: "Web3.swift"),
            ]),
        .testTarget(
            name: "FiatNestTests",
            dependencies: ["FiatNest"]),
    ]
) 