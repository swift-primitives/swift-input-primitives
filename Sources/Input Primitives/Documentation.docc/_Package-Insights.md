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

## Topics

### Related Documents

- <doc:Input>
