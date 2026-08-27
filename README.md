# Input

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Foundation-free input cursor primitives for Swift. The package separates forward
streaming, checkpointable input, and random access into a small protocol hierarchy,
with `Input.Buffer` as its standard owned-storage implementation.

## Quick start

```swift
import Input

var input = Input.Buffer([1, 2, 3, 4, 5])
let checkpoint = input.checkpoint

let first = try input.removeFirst()
let second = try input.removeFirst()

try input.restore(to: checkpoint)

assert(first == 1)
assert(second == 2)
assert(input.first == 1)
```

Counts, offsets, and `Input.Buffer` checkpoints use native `Int` values. The atom
does not depend on derived index, property-view, collection, or parser surfaces.

## Installation

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-atoms/swift-input.git",
        branch: "main"
    ),
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Input", package: "swift-input"),
    ]
)
```

The package requires Swift 6.4. Until its first release, depend on `main`.

## Products

| Product | Purpose |
|---|---|
| `Input` | Foundation-free protocol hierarchy, operations, errors, and `Input.Buffer` |
| `Input Standard Library Integration` | Standard-library conformances, currently `Optional: Input.Restorable` |
| `Input Apple Foundation Integration` | Apple Foundation integration boundary |

## Capability hierarchy

`Input.Stream.Protocol` provides `isEmpty` and `advance()`. Its defaults add
`next()` and the typed-error `removeFirst()` operation.

`Input.Protocol` refines streaming with a checkpoint, remaining count, valid
checkpoint bounds, `seek(to:)`, and `advance(by:)`. Its defaults add checkpoint
validation and `restore(to:)`.

`Input.Access.Random` adds integer-offset subscripting, checked `element(at:)`,
and prefix lookahead through `starts(with:)`.

```swift
var input = Input.Buffer([10, 20, 30, 40])

try input.removeFirst(2)
assert(input.consumed == 2)
assert(input.count == 2)
assert(input[offset: 0] == 30)
let last = try input.element(at: 1)
assert(last == 40)
```

`Input.Restorable` also supports value checkpoints directly. A copyable value whose
checkpoint is itself receives default `checkpoint` and `seek(to:)` implementations.

## Foundation and Embedded

The `Input` and `Input Standard Library Integration` targets do not import
Foundation. Foundation is confined to `Input Apple Foundation Integration`, keeping
the native core suitable for Embedded-profile convergence.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
