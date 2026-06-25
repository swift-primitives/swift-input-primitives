// swift-linter-tools-version: 0.1
// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-input-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-input-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Shape-γ unified consumer manifest. swift-input-primitives does NOT
// own a brand-newtype that motivates per-package rule exclusion — the
// full primitives bundle applies as-is.
//
// If a future rule fires on legitimate-by-construction code in this
// package, add a typed entry to `.excluding(rules:)` with a `// reason:`
// citation, mirroring the swift-cyclic-primitives precedent. The
// cleaner destination remains AST-layer rule refinement at
// `swift-foundations/swift-linter-rules` (likely as `[RULE-EXEMPT-N]`
// shapes per the `rule-exemptions` skill); per-package `.excluding` is
// a stopgap.

import Linter
import Linter_Primitives_Rules

Lint.run(dependencies: [
    .package(
        path: "../swift-primitives-linter-rules",
        products: ["Linter Primitives Rules"]
    ),
]) {
    Lint.Rule.Bundle.primitives
}
