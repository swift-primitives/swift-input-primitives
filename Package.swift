// swift-tools-version: 6.3.1

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
        // MARK: - Sub-targets
        .library(
            name: "Input Access Primitives",
            targets: ["Input Access Primitives"]
        ),
        .library(
            name: "Input Buffer Primitives",
            targets: ["Input Buffer Primitives"]
        ),
        .library(
            name: "Input Namespace Primitives",
            targets: ["Input Namespace Primitives"]
        ),
        .library(
            name: "Input Protocol Primitives",
            targets: ["Input Protocol Primitives"]
        ),
        .library(
            name: "Input Remove Primitives",
            targets: ["Input Remove Primitives"]
        ),
        .library(
            name: "Input Restore Primitives",
            targets: ["Input Restore Primitives"]
        ),
        .library(
            name: "Input Slice Primitives",
            targets: ["Input Slice Primitives"]
        ),
        .library(
            name: "Input Stream Primitives",
            targets: ["Input Stream Primitives"]
        ),

        // MARK: - Umbrella
        .library(
            name: "Input Primitives",
            targets: ["Input Primitives"]
        ),

        // MARK: - Test Support
        .library(
            name: "Input Primitives Test Support",
            targets: ["Input Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-collection-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-equation-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-comparison-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-hash-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-property-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-iterator-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Namespace
        .target(
            name: "Input Namespace Primitives"
        ),

        // MARK: - Stream
        .target(
            name: "Input Stream Primitives",
            dependencies: [
                "Input Namespace Primitives",
            ]
        ),

        // MARK: - Protocol
        .target(
            name: "Input Protocol Primitives",
            dependencies: [
                "Input Namespace Primitives",
                "Input Stream Primitives",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        // MARK: - Access
        .target(
            name: "Input Access Primitives",
            dependencies: [
                "Input Namespace Primitives",
                "Input Protocol Primitives",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        // MARK: - Remove
        .target(
            name: "Input Remove Primitives",
            dependencies: [
                "Input Namespace Primitives",
                "Input Protocol Primitives",
                "Input Stream Primitives",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        // MARK: - Restore
        .target(
            name: "Input Restore Primitives",
            dependencies: [
                "Input Namespace Primitives",
                "Input Protocol Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        // MARK: - Buffer
        .target(
            name: "Input Buffer Primitives",
            dependencies: [
                "Input Access Primitives",
                "Input Namespace Primitives",
                "Input Protocol Primitives",
                "Input Stream Primitives",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        // MARK: - Slice
        .target(
            name: "Input Slice Primitives",
            dependencies: [
                "Input Access Primitives",
                "Input Namespace Primitives",
                "Input Protocol Primitives",
                .product(name: "Collection Primitives", package: "swift-collection-primitives"),
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
                .product(name: "Equation Primitives", package: "swift-equation-primitives"),
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Input Primitives",
            dependencies: [
                "Input Access Primitives",
                "Input Buffer Primitives",
                "Input Namespace Primitives",
                "Input Protocol Primitives",
                "Input Remove Primitives",
                "Input Restore Primitives",
                "Input Slice Primitives",
                "Input Stream Primitives",
            ]
        ),

        // MARK: - Test Support
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
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
