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
            url: "https://github.com/swift-atoms/swift-affine.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-carrier.git",
            branch: "main"
        ),
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
            url: "https://github.com/swift-atoms/swift-ordinal.git",
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
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
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
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
            ]
        ),

        .target(
            name: "Input Access",
            dependencies: [
                .target(name: "Input Namespace"),
                .target(name: "Input Protocol"),
                .product(name: "Affine Arithmetic", package: "swift-affine"),
                .product(name: "Affine Carrier", package: "swift-affine"),
                .product(name: "Affine Discrete", package: "swift-affine"),
                .product(name: "Affine Tagged", package: "swift-affine"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Cardinal Error", package: "swift-cardinal"),
                .product(name: "Cardinal Tagged", package: "swift-cardinal"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "Input Remove",
            dependencies: [
                .target(name: "Input Namespace"),
                .target(name: "Input Protocol"),
                .target(name: "Input Stream"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "Input Restore",
            dependencies: [
                .target(name: "Input Namespace"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
            ]
        ),

        .target(
            name: "Input Buffer",
            dependencies: [
                .target(name: "Input Access"),
                .target(name: "Input Namespace"),
                .target(name: "Input Protocol"),
                .target(name: "Input Stream"),
                .product(name: "Affine Discrete", package: "swift-affine"),
                .product(name: "Affine Tagged", package: "swift-affine"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Cardinal Error", package: "swift-cardinal"),
                .product(name: "Cardinal Tagged", package: "swift-cardinal"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Ordinal Cardinal", package: "swift-ordinal"),
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
                .product(name: "Ordinal Tagged", package: "swift-ordinal"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "Input Slice",
            dependencies: [
                .target(name: "Input Access"),
                .target(name: "Input Namespace"),
                .target(name: "Input Protocol"),
                .product(name: "Affine Arithmetic", package: "swift-affine"),
                .product(name: "Affine Tagged", package: "swift-affine"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Cardinal Tagged", package: "swift-cardinal"),
                .product(name: "Collection Protocol", package: "swift-collection"),
                .product(name: "Collection Slice", package: "swift-collection"),
                .product(name: "Comparison Protocol", package: "swift-comparison"),
                .product(name: "Equation Protocol", package: "swift-equation"),
                .product(name: "Hash Protocol", package: "swift-hash"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Ordinal Cardinal", package: "swift-ordinal"),
                .product(name: "Ordinal Distance", package: "swift-ordinal"),
                .product(name: "Ordinal Error", package: "swift-ordinal"),
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
                .product(name: "Ordinal Tagged", package: "swift-ordinal"),
                .product(name: "Sequence Borrowing", package: "swift-sequence"),
                .product(name: "Tagged", package: "swift-tagged"),
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
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Cardinal Error", package: "swift-cardinal"),
                .product(name: "Cardinal Tagged", package: "swift-cardinal"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Index Test Support", package: "swift-index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
                .product(name: "Ordinal Successor", package: "swift-ordinal"),
                .product(name: "Ordinal Tagged", package: "swift-ordinal"),
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Input Tests",
            dependencies: [
                .target(name: "Input"),
                .target(name: "Input Test Support"),
                .product(name: "Affine Tagged", package: "swift-affine"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Carrier Protocol", package: "swift-carrier"),
                .product(name: "Collection Protocol", package: "swift-collection"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Ordinal Error", package: "swift-ordinal"),
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
                .product(name: "Ordinal Successor", package: "swift-ordinal"),
                .product(name: "Ordinal Tagged", package: "swift-ordinal"),
                .product(name: "Sequence Borrowing", package: "swift-sequence"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Tagged Standard Library Integration", package: "swift-tagged"),
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
