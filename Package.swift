// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-input-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Input Primitives",
            targets: ["Input Primitives"]
        ),
        .library(
            name: "Input Primitives Test Support",
            targets: ["Input Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-collection-primitives"),
        .package(path: "../swift-equation-primitives"),
        .package(path: "../swift-comparison-primitives"),
        .package(path: "../swift-hash-primitives"),
        .package(path: "../swift-property-primitives"),
        .package(path: "../swift-identity-primitives"),
        .package(path: "../swift-index-primitives"),
    ],
    targets: [
        .target(
            name: "Input Primitives",
            dependencies: [
                .product(name: "Collection Primitives", package: "swift-collection-primitives"),
                .product(name: "Equation Primitives", package: "swift-equation-primitives"),
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Identity Primitives", package: "swift-identity-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),
        .target(
            name: "Input Primitives Test Support",
            dependencies: [
                "Input Primitives",
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Input Primitives Tests",
            dependencies: [
                "Input Primitives",
                "Input Primitives Test Support",
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
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
