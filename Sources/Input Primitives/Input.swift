//
//  Input.swift
//  swift-input-primitives
//
//  Namespace for input primitives providing consumable, checkpointable cursors.
//

/// Namespace for input primitives.
///
/// `Input` provides the minimum complete basis for consumable, checkpointable
/// inputs that higher layers (Parsing, Machine executors, Binary cursors) can
/// build on without importing Parsing itself.
///
/// ## Protocol Hierarchy
///
/// ```
/// Input.Streaming      ← minimal forward-only (isEmpty, first, removeFirst)
///        ↑
/// Input.Protocol       ← adds checkpoint/restore, count, removeFirst(n)
///        ↑
/// Input.Access.Random  ← adds subscript(offset:), starts(with:)
/// ```
///
/// ## Concrete Types
///
/// - ``Input/Slice``: Zero-copy cursor over any `Collection`
/// - ``Input/Buffer``: Owned buffer cursor with integer position
///
/// ## Standard Library Bridging
///
/// Standard library types (`ArraySlice`, `Substring`, `Substring.UTF8View`) do not
/// conform directly to `Input.Protocol` because their slicing semantics prevent
/// backward checkpoint restore. Use the wrapper types instead:
///
/// - `Input.Slice(array[...])` for array-backed parsing with full backtracking
/// - `Input.Slice("text"[...].utf8)` for UTF-8 text parsing with full backtracking
/// - `Input.Buffer(array)` for owned buffer parsing
///
/// ## Example
///
/// ```swift
/// var input = Input.Buffer([0x48, 0x65, 0x6C, 0x6C, 0x6F])
/// let checkpoint = input.checkpoint
/// let first = input.removeFirst()  // 0x48
/// input.restore(to: checkpoint)
/// assert(input.first == 0x48)      // Back to start
/// ```
///
/// ## Scope
///
/// This package owns exactly this problem: A value that represents a positioned
/// view over a finite sequence, supports consumption, backtracking, peeking,
/// and prefix checks, without prescribing parsing combinators or grammar semantics.
///
/// ## Future: Input.Borrowed
///
/// A borrowed input type (analogous to `Binary.Bytes.Input.View`) is planned
/// but deferred pending:
/// 1. Stable `~Escapable` support in protocol associated types
/// 2. Generic lifetime parameterization
///
/// For now, use `Binary.Bytes.Input.View` for zero-copy borrowed parsing,
/// or `Input.Buffer`/`Input.Slice` for owned/shared cursors.
public enum Input {}
