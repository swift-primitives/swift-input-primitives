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
        .package(path: "../swift-property-primitives"),
        .package(path: "../swift-identity-primitives"),
        .package(path: "../swift-index-primitives"),
    ],
    targets: [
        .target(
            name: "Input Primitives",
            dependencies: [
                .product(name: "Collection Primitives", package: "swift-collection-primitives"),
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
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("NonescapableTypes"),
        .enableExperimentalFeature("LifetimeDependence"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
