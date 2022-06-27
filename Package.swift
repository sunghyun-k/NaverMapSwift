// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NaverMapSwift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "NaverMapSwift",
            targets: ["NaverMapSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jaemyeong/NMapsMap-SPM.git", .upToNextMajor(from: "3.15.0")),
    ],
    targets: [
        .target(
            name: "NaverMapSwift",
            dependencies: [
                .product(name: "NMapsMap", package: "NMapsMap-SPM"),
            ],
            path: "Sources"
        ),
    ]
)
