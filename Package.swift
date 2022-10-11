// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storages",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "Storages", targets: ["Storages"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Storages", dependencies: [])
    ]
)
