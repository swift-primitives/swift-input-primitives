# Input Primitives Insights

<!--
---
title: Input Primitives Insights
version: 1.0.0
last_updated: 2026-01-20
applies_to: [swift-input-primitives]
normative: false
---
-->

@Metadata {
    @TitleHeading("Input Primitives")
}

Design decisions, implementation patterns, and lessons learned specific to this package.

## Overview

This document captures insights that emerged during development of swift-input-primitives. These are not API requirements—they are recorded decisions and patterns that inform future work on this package.

**Document type**: Non-normative (recorded decisions, not requirements).

**Consolidation source**: Reflection entries tagged with `[Package: swift-input-primitives]`.

---

## The Forward-Only Slicing Problem

**Date**: 2026-01-19

**Context**: Investigating why `Substring`, `ArraySlice`, and `Substring.UTF8View` cannot safely conform to `Input.Protocol`.

### The Limitation

All three Swift standard library "view" types share a fundamental limitation: their slicing operator `self[checkpoint...]` cannot access indices before the current `startIndex`. When you slice forward, you lose the ability to go back.

This breaks `Input.Protocol`'s checkpoint/restore contract:

```swift
var input = "hello"[...].utf8
let checkpoint = input.checkpoint  // saves current startIndex
_ = input.removeFirst()            // advances startIndex
input.restore(to: checkpoint)      // CRASH: checkpoint is before new startIndex
```

The slicing `self[checkpoint...]` fails because `checkpoint` is no longer a valid lower bound.

### Why All Three Types Failed

Initially, `Substring.UTF8View` seemed viable because its `count` and `Element` semantics match (unlike `Substring` where `count` returns characters but iteration is O(n)). But testing checkpoint/restore revealed the same crash:

```swift
extension Substring.UTF8View: Input.Protocol {
    public mutating func restore(to checkpoint: Checkpoint) {
        self = self[checkpoint...]  // Forward-only: checkpoint must be >= startIndex
    }
}
```

The conformance compiled. The tests crashed. The limitation is structural, not incidental.

### Removal Over Documentation

The instinct was to document the limitation: "Note: ArraySlice conformance only supports forward-only restore." But this violates the contract. Code generic over `Input.Protocol` assumes backward restore works. Documentation warnings don't prevent runtime crashes.

The correct action: remove all three conformances entirely. Users who need stdlib-backed input should use `Input.Slice`:

```swift
var input = Input.Slice("hello"[...].utf8)  // Full checkpoint/restore
var input = Input.Slice(array[...])          // Full checkpoint/restore
```

`Input.Slice` stores the original base collection and an index range. Restore simply adjusts the range. No slicing, no lost indices.

### The Broader Principle

When a protocol contract cannot be satisfied by a type's fundamental semantics, do not ship a broken conformance with documentation. Either:

1. Remove the conformance entirely, or
2. Change the protocol to have weaker guarantees (if that makes semantic sense)

For `Input.Protocol`, weakening the contract would break all existing generic code. Removal is the only correct path.

### No Stdlib Conformances

This leads to a broader principle for primitives packages: **avoid adding protocol conformances to stdlib types when the protocol's semantics differ from stdlib's semantics**.

Stdlib collections optimize for different invariants than parsing input:
- `Collection.removeFirst()` returns `Void`; `Input.Streaming.removeFirst()` returns `Element`
- Stdlib slicing is forward-only; parsing needs backtracking

These are different abstractions. Wrapper types bridge them safely.

**Applies to**: `Input.Protocol`, `Input.Streaming`, any protocol requiring backtracking over collections.

---

## Swift's Return-Type Overload Prohibition

**Date**: 2026-01-19

**Context**: Designing a "total" variant of `removeFirst()` that returns `nil` instead of trapping when empty.

### The Language Constraint

The natural design seemed obvious:

```swift
// Preconditioned (traps if empty)
mutating func removeFirst() -> Element

// Total (returns nil if empty)
mutating func removeFirst() -> Element?
```

This does not compile. Swift prohibits overloading solely on return type. The call site `input.removeFirst()` is ambiguous—the compiler cannot determine which overload without explicit type annotation.

### The Stdlib Solution

Swift's standard library faced this same problem with `Collection.popFirst()`:

```swift
// Collection already has:
mutating func removeFirst() -> Element  // Precondition: !isEmpty

// And separately:
mutating func popFirst() -> Element?    // Returns nil if empty
```

Different names, not overloaded return types.

### Applying the Pattern

For `Input.Streaming`, the solution follows stdlib:

```swift
extension Input.Streaming {
    public mutating func popFirst() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
}
```

The naming mirrors stdlib. Developers familiar with `Collection.popFirst()` will expect `Input.Streaming.popFirst()` to behave identically.

### Constraints as Clarification

This is a case where Swift's type system forces a naming decision. The prohibition makes the decision: different behavior requires different names.

Sometimes constraints are clarifying. The "failure" to overload on return type produces a cleaner API—explicit opt-in to the total variant via a distinct name, rather than implicit selection via type context.

**Applies to**: `Input.Streaming.popFirst()`, any total/partial API pairs.

---

## Discovering Dead Code Through Testing

**Date**: 2026-01-19

**Context**: The original `Substring.UTF8View` conformance existed in the codebase, appeared correct, but had never been exercised by tests.

### The Dangerous Conformance

The conformance looked reasonable:

```swift
extension Substring.UTF8View: Input.Protocol {
    public typealias Element = UInt8
    public typealias Checkpoint = Index

    public var checkpoint: Checkpoint { startIndex }
    public mutating func restore(to checkpoint: Checkpoint) {
        self = self[checkpoint...]
    }
}
```

But `removeFirst() -> Element` and `removeFirst(_ n: Int)` were missing. Swift didn't complain because the conformance was never used. No tests instantiated it. No production code exercised it.

### Tests as Existence Proofs

A protocol conformance without tests is an unverified claim. The compiler checks syntax; tests check semantics. Without a test that:

1. Creates the conforming type
2. Exercises the protocol's methods
3. Verifies the contract (especially edge cases like "restore after consumption")

...the conformance is dead code. Dead code that happens to compile.

### The Crash Test

Adding the missing methods and writing a test immediately revealed the problem:

```swift
@Test func checkpointRestoreWorks() {
    var input = "hello"[...].utf8
    let cp = input.checkpoint
    _ = input.removeFirst()
    _ = input.removeFirst()
    input.restore(to: cp)  // CRASH
    #expect(input.first == UInt8(ascii: "h"))
}
```

The test crashed. The conformance was wrong. But it had existed—untested—for an unknown period.

### The Discipline

Every protocol conformance needs a test that exercises the protocol's full contract, including:

- Edge cases (empty collections, single elements)
- State transitions (checkpoint before/after mutation)
- Round-trip invariants (checkpoint → mutate → restore → original state)

Compiling is necessary but not sufficient. "The tests pass" means the tests ran. "The conformance is correct" means the tests *exist and cover the contract*.

**Applies to**: All protocol conformances, especially those with behavioral contracts beyond type constraints.

---

## Ambiguity at the Intersection of Conformances

**Date**: 2026-01-19

**Context**: After adding `popFirst()` to `Input.Streaming`, tests using `input.popFirst() != nil` failed with "ambiguous use of operator '!='" and "ambiguous use of 'popFirst()'".*

### The Collision

`Input.Slice` conforms to both `Input.Streaming` (our protocol) and `Collection` (from stdlib via conditional conformance). Both protocols provide `popFirst() -> Element?`:

```swift
// Our Input.Streaming default implementation
extension Input.Streaming {
    public mutating func popFirst() -> Element? { ... }
}

// Swift stdlib Collection
extension Collection {
    public mutating func popFirst() -> Element? { ... }
}
```

When calling `slice.popFirst()`, the compiler sees two equally valid methods. Ambiguity.

### Why `!= nil` Made It Worse

The expression `input.popFirst() != nil` compounds the ambiguity. The compiler must resolve:

1. Which `popFirst()`?
2. Which `!=` overload? (There are many for optionals)

The combination of ambiguities makes the error message confusing—it complains about the operator when the real problem is the method.

### The Fix

Avoid the ambiguous pattern entirely:

```swift
// Ambiguous
while input.popFirst() != nil { }

// Unambiguous
while !input.isEmpty {
    _ = input.removeFirst()
}
```

This sidesteps the collision by using `isEmpty` (unambiguous) and `removeFirst()` (also unambiguous—stdlib's returns `Void` for slices, ours returns `Element`).

### Broader Lesson

When adding methods to a protocol that conforming types might also inherit from stdlib, name collisions are possible. Options:

1. **Different name**: Avoid stdlib method names (`consumeFirst()` instead of `popFirst()`)
2. **Accept shadowing**: If your semantics match stdlib's, shadowing is fine
3. **Document the ambiguity**: If conforming types may hit it, document the workaround

For `Input.Streaming`, we kept `popFirst()` because it matches stdlib semantics exactly. Types that conform to both will have ambiguity, but the behavior is identical—either resolution produces correct results.

**Applies to**: `Input.Slice`, any type conforming to both primitives protocols and stdlib protocols.

---

## Topics

### Related Documents

- <doc:Input>
