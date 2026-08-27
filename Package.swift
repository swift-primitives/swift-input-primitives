// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-input",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Input",
            targets: ["Input"]
        ),
        .library(
            name: "Input Standard Library Integration",
            targets: ["Input Standard Library Integration"]
        ),
        .library(
            name: "Input Apple Foundation Integration",
            targets: ["Input Apple Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-property.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Input",
            dependencies: [
                .product(name: "Index", package: "swift-index"),
                .product(name: "Property", package: "swift-property"),
            ]
        ),
        .target(
            name: "Input Standard Library Integration",
            dependencies: ["Input"]
        ),
        .target(
            name: "Input Apple Foundation Integration",
            dependencies: [
                "Input",
                "Input Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Input Tests",
            dependencies: [
                "Input",
                .product(name: "Index", package: "swift-index"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
