# Input Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Consumable, checkpointable cursors for Swift — `Input.Protocol` with checkpoint/restore backtracking, a parallel `Input.Stream.Protocol` → `Input.Protocol` → `Input.Access.Random` capability hierarchy, and zero-copy / owned-buffer concrete conformers (`Input.Slice`, `Input.Buffer`) ready to back parser combinators, machine executors, and binary cursors without importing parsing itself.

The cursor pattern in this package serves the same role as `Foundation.Scanner` or `Swift.Substring` does in informal-parser code, but typed end-to-end: positions are `Tagged<Element, Ordinal>` (`Index<Element>`), counts are `Index<Element>.Count`, and the protocol surface separates *what-you-can-do* (consume / advance) from *what-you-can-undo* (checkpoint / restore) from *what-you-can-jump-to* (random-access subscript) — each capability adds typed operations on top of the prior without losing the `~Copyable` element story. Move-only element types (file descriptors, unique resource handles, `Span<T>`) flow through the cursor surface end-to-end.

---

## Quick Start

```swift
import Input_Primitives

// `Input.Buffer` owns a byte array and exposes a checkpointable cursor.
var input = Input.Buffer([1, 2, 3, 4, 5])

// Save the current position, consume, and restore.
let cp = input.checkpoint

let first = try input.remove.first()    // Optional(1)
let second = try input.remove.first()   // Optional(2)
// input.first == 3

try input.restore.to(cp)
// input.first == 1 again — backtracking succeeded.

// `consumed` reports the count of elements consumed since construction;
// `bounds` reports the valid range of checkpoint positions.
let count: Index<Int>.Count = input.consumed
let valid: ClosedRange = input.bounds
```

```swift
// Zero-copy slice cursor over an existing Collection.Protocol conformer.
let storage = MyContainer([10, 20, 30, 40, 50])
var slice = Input.Slice(storage)

// Slice satisfies Input.Protocol — same checkpoint/restore/consume surface
// as Input.Buffer, but the elements are borrowed from the underlying
// container rather than owned.
```

For `~Copyable` element types — file descriptors, unique resource handles, `Span<T>` — both `Input.Slice` and `Input.Buffer` thread the constraint through. The cursor never copies the element; consuming the cursor consumes the value.

---

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-input-primitives.git", branch: "main"),
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Input Primitives", package: "swift-input-primitives"),
    ]
)
```

The package is pre-1.0 — until 0.1.0 is tagged, depend on `branch: "main"` rather than `from: "0.1.0"`. Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Nine variant libraries plus an umbrella product and a Test Support spine. Consumers default to the umbrella; targeted imports are available when fine-grained dependency management matters.

| Product | When to import | What's in it |
|---------|---------------|--------------|
| `Input Primitives` | Default for application code | The full protocol family + concrete cursors. Re-exports all 8 sub-targets so a single `import Input_Primitives` brings the entire surface into scope. |
| `Input Namespace Primitives` | Defining the `Input` namespace shell from a sibling package | Just the `public enum Input` namespace shell. |
| `Input Protocol Primitives` | Conforming a custom cursor type to `Input.Protocol` | `Input.Protocol` + default impls (validation, advance, etc.). |
| `Input Stream Primitives` | Stream-only cursors that don't need checkpointing | `Input.Stream.Protocol` + `Input.Stream` namespace + `Input.Stream.Error`. |
| `Input Access Primitives` | Cursors with random-access subscript | `Input.Access.Random` + `Input.Access.Error`. |
| `Input Buffer Primitives` | Owned-buffer cursor types | `Input.Buffer<Storage>` + protocol conformances. |
| `Input Slice Primitives` | Zero-copy slice cursors over `Collection.Protocol` conformers | `Input.Slice<Base>` + protocol conformances (Input, Collection.Slice, Comparison, Equation, Hash). |
| `Input Remove Primitives` | The fluent `.remove.first()` / `.remove.first(_:)` surface | `Input.Remove` View + `Input.Remove.Error`. |
| `Input Restore Primitives` | The fluent `.restore.to(_:)` surface | `Input.Restore` View + `Input.Restore.Error`. |
| `Input Primitives Test Support` | Test targets | `Input.Fixture.Source` and re-exports for downstream test consumers. |

Foundation-free. No concurrency surface. No platform conditionals.

### Three-tier capability hierarchy

`Input.Stream.Protocol`, `Input.Protocol`, and `Input.Access.Random` form a strict refinement chain — each adds operations on top of the prior without losing the move-only element story.

| Aspect | `Input.Stream.Protocol` | `Input.Protocol` | `Input.Access.Random` |
|--------|------------------------|------------------|----------------------|
| Forward iteration (`isEmpty`, `first`, `.remove.first()`) | Yes | Yes | Yes |
| Checkpoint capture + restore (`checkpoint`, `.restore.to(_:)`) | — | Yes | Yes |
| Position bounds + advance (`bounds`, `seek(to:)`) | — | Yes | Yes |
| Random-access subscript + lookahead (`subscript(offset:)`, `.starts(with:)`) | — | — | Yes |

A cursor type conforms to whichever level its underlying storage supports: linear stream readers stop at `Input.Stream.Protocol`; checkpointable cursors over indexed collections reach `Input.Protocol`; cursors over O(1)-indexed storage reach `Input.Access.Random` for parser-combinator lookahead.

### Fluent surface via Property.Inout

The cursor operations — `.remove.first()`, `.remove.first(_:)`, `.restore.to(_:)` — are provided by `Property<Tag, Base>.Inout` accessors from `swift-property-primitives`. Conformers do not implement the View types; satisfying the protocol primitives is sufficient. The phantom-tagged Property machinery makes the call-site form (`input.remove.first()`) compose with `~Copyable` cursor types without forcing copies.

`.remove.first(_:Index<Element>.Count)` removes a typed count of elements; the typed `Count` parameter rules out arithmetic mistakes that `Int` would silently allow. The fluent `.restore.to(_:)` calls into the protocol primitive `seek(to:)`, which conformers implement directly.

### Slice vs Buffer

`Input.Slice<Base>` is a zero-copy cursor over an existing `Collection.Protocol` conformer — the cursor's storage IS the underlying collection, with the cursor's typed position threading through `Index<Base.Element>` arithmetic. `Input.Buffer<Storage>` owns its storage; constructing from `[UInt8]` (or any element type) gives an independently-owned cursor that can outlive the constructing scope. The fluent operation surface (`.remove`, `.restore`) is identical between the two.

---

## Concrete cursors

```swift
// Buffer cursor — owned [Element] storage; cheap to construct from a literal.
var buffer = Input.Buffer([0xDE, 0xAD, 0xBE, 0xEF])

// Slice cursor — zero-copy over an existing Collection.Protocol conformer.
var slice = Input.Slice(myStorage)

// Both expose the same surface from Input.Protocol:
buffer.consumed                       // Index<UInt8>.Count
buffer.checkpoint                     // current position (Index<UInt8>)
buffer.bounds                         // ClosedRange of valid checkpoints
try buffer.remove.first()             // Optional<UInt8>
try buffer.remove.first(2)            // Removes 2 elements
try buffer.restore.to(savedCheckpoint)
```

---

## Platform Support

| Platform | CI | Status |
|----------|-----|--------|
| macOS 26 | Yes | Full support |
| iOS / tvOS / watchOS / visionOS | — | Supported |
| Linux | Yes | Full support |
| Windows | Yes | Full support |
| Swift Embedded | — | Possible (no Foundation, no concurrency surface; first-party Embedded matrix runs post-flip) |

---

## Stability

Pre-1.0. The public API of `Input.Protocol` and its members may change while the package remains on `branch: "main"`; consumers should expect breaking changes to surface in commit messages until the first tag. Once tagged, the package follows institute SemVer: post-1.0 breaking changes ship behind a major bump.

| Surface | 0.1.x expectation |
|---|---|
| Public type names (`Input.Protocol`, `Input.Stream.Protocol`, `Input.Access.Random`, `Input.Slice`, `Input.Buffer`) | Stable within 0.1.x |
| Fluent `.remove`, `.restore` accessor surfaces | Stable within 0.1.x |
| Protocol primitives (`consumed`, `bounds`, `seek(to:)`, `checkpoint`) | Stable within 0.1.x |
| Internal storage shapes and `@usableFromInline` helpers | Not part of the source-stability commitment |

---

## Related Packages

Direct dependencies (all already-public):

- [swift-collection-primitives](https://github.com/swift-primitives/swift-collection-primitives) — `Collection.Protocol` family + `Collection.Slice.Protocol`, the bridges `Input.Slice` conforms to for indexed cursor access.
- [swift-sequence-primitives](https://github.com/swift-primitives/swift-sequence-primitives) — `Sequence.Protocol` + `Sequence.Iterator.Protocol`, the iterator family the slice cursor's `CollectionIterator` conforms to.
- [swift-index-primitives](https://github.com/swift-primitives/swift-index-primitives) — `Index<Element>`, `Index.Offset`, `Index.Count`, the typed-position surface every cursor stores positions in.
- [swift-property-primitives](https://github.com/swift-primitives/swift-property-primitives) — `Property<Tag, Base>.Inout`, the phantom-tagged fluent-accessor machinery that powers `.remove.first()`, `.restore.to(_:)`, and friends.
- [swift-comparison-primitives](https://github.com/swift-primitives/swift-comparison-primitives), [swift-equation-primitives](https://github.com/swift-primitives/swift-equation-primitives), [swift-hash-primitives](https://github.com/swift-primitives/swift-hash-primitives) — base protocols `Input.Slice` conforms to for comparator/equator/hasher integration in parser combinators.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
