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
            name: "Input Access",
            targets: ["Input Access"]
        ),
        .library(
            name: "Input Buffer",
            targets: ["Input Buffer"]
        ),
        .library(
            name: "Input Namespace",
            targets: ["Input Namespace"]
        ),
        .library(
            name: "Input Protocol",
            targets: ["Input Protocol"]
        ),
        .library(
            name: "Input Remove",
            targets: ["Input Remove"]
        ),
        .library(
            name: "Input Restore",
            targets: ["Input Restore"]
        ),
        .library(
            name: "Input Slice",
            targets: ["Input Slice"]
        ),
        .library(
            name: "Input Stream",
            targets: ["Input Stream"]
        ),

        .library(
            name: "Input",
            targets: ["Input"]
        ),

        .library(
            name: "Input Test Support",
            targets: ["Input Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-collection.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-equation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-comparison.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-hash.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-property.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-byte.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-iterator.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-sequence.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Input Namespace"
        ),

        .target(
            name: "Input Stream",
            dependencies: [
                .target(name: "Input Namespace")
            ]
        ),

        .target(
            name: "Input Protocol",
            dependencies: [
                .target(name: "Input Namespace"),
                .target(name: "Input Restore"),
                .target(name: "Input Stream"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Input Access",
            dependencies: [
                .target(name: "Input Namespace"),
                .target(name: "Input Protocol"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Input Remove",
            dependencies: [
                .target(name: "Input Namespace"),
                .target(name: "Input Protocol"),
                .target(name: "Input Stream"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Input Restore",
            dependencies: [
                .target(name: "Input Namespace"),
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Input Buffer",
            dependencies: [
                .target(name: "Input Access"),
                .target(name: "Input Namespace"),
                .target(name: "Input Protocol"),
                .target(name: "Input Stream"),
                .product(name: "Index", package: "swift-index"),
            ]
        ),

        .target(
            name: "Input Slice",
            dependencies: [
                .target(name: "Input Access"),
                .target(name: "Input Namespace"),
                .target(name: "Input Protocol"),
                .product(name: "Collection", package: "swift-collection"),
                .product(name: "Comparison", package: "swift-comparison"),
                .product(name: "Equation", package: "swift-equation"),
                .product(name: "Hash", package: "swift-hash"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Iterable", package: "swift-iterator"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Input",
            dependencies: [
                .target(name: "Input Access"),
                .target(name: "Input Buffer"),
                .target(name: "Input Namespace"),
                .target(name: "Input Protocol"),
                .target(name: "Input Remove"),
                .target(name: "Input Restore"),
                .target(name: "Input Slice"),
                .target(name: "Input Stream"),
            ]
        ),

        .target(
            name: "Input Test Support",
            dependencies: [
                .target(name: "Input"),
                .product(name: "Index Test Support", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Input Tests",
            dependencies: [
                .target(name: "Input"),
                .target(name: "Input Test Support"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Sequence", package: "swift-sequence"),
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
