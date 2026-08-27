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
    dependencies: [],
    targets: [
        .target(
            name: "Input",
            dependencies: []
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
            dependencies: ["Input"]
        ),
        .testTarget(
            name: "Input Standard Library Integration Tests",
            dependencies: [
                "Input",
                "Input Standard Library Integration",
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
