//
//  Input.Stream.Protocol.swift
//  swift-input-primitives
//
//  Base protocol for streaming (non-backtracking) input sources.
//

extension Input.Stream {
    /// A type that can be used as streaming input.
    ///
    /// `Input.Stream.Protocol` represents the minimal interface for forward-only input:
    /// - Check for end of input (`isEmpty`)
    /// - Peek at next element (`first`)
    /// - Consume elements via `advance()` or `remove` accessor
    ///
    /// Unlike ``Input/Protocol``, this protocol does not require checkpointing
    /// or backtracking support, making it suitable for:
    /// - Network streams (where bytes cannot be re-read)
    /// - Large file parsing (where buffering is expensive)
    /// - Committed-choice parsing (where backtracking is not needed)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var input = Input.Buffer([1, 2, 3])
    /// while !input.isEmpty {
    ///     let element = try input.advance()
    ///     process(element)
    /// }
    /// ```
    ///
    /// ## Totality
    ///
    /// All operations are total per [API-IMPL-003]:
    /// - `isEmpty` and `first` are inherently total
    /// - `advance()` uses typed throws via ``Input/Stream/Error``
    ///
    /// ## Protocol Hierarchy
    ///
    /// ```
    /// Input.Stream.Protocol  ← minimal, forward-only
    ///       ↑
    /// Input.Protocol         ← adds checkpoint/restore for backtracking
    ///       ↑
    /// Input.Access.Random    ← adds subscript(offset:), access.starts(with:)
    /// ```
    ///
    /// ## Element Type Constraint
    ///
    /// The `Element` associated type implicitly requires `Copyable` per
    /// [SE-0427](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0427-noncopyable-generics.md).
    /// Swift does not yet support `associatedtype Element: ~Copyable`.
    ///
    /// This limitation is **language-level**, not a design choice:
    /// - SE-0427 deferred `~Copyable` suppression on associated types
    /// - Standard library collections also require `Copyable` elements
    /// - Future Swift versions may lift this restriction
    ///
    /// ## Borrowing Semantics
    ///
    /// Conformers SHOULD implement `first` using the `_read` coroutine accessor
    /// to provide borrowing semantics, avoiding unnecessary copies:
    ///
    /// ```swift
    /// var first: Element? {
    ///     _read {
    ///         if position < storage.endIndex {
    ///             yield storage[position]
    ///         } else {
    ///             yield nil
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// This prepares for [SE-0474](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0474-yielding-accessors.md)
    /// which will formalize `yielding borrow` as a protocol requirement:
    ///
    /// ```swift
    /// // Future API when SE-0474 is available:
    /// var first: Element? { yielding borrow }
    /// ```
    ///
    /// ## Future Direction
    ///
    /// The "timeless" API requires two language features:
    ///
    /// | Feature | Purpose | Status |
    /// |---------|---------|--------|
    /// | `associatedtype Element: ~Copyable` | Allow noncopyable elements | Awaits future SE |
    /// | `{ yielding borrow }` in protocols | Require borrowing access | SE-0474 (not yet stable) |
    ///
    /// When both are available, this protocol will evolve to:
    ///
    /// ```swift
    /// public protocol `Protocol`: ~Copyable {
    ///     associatedtype Element: ~Copyable
    ///     var first: Element? { yielding borrow }
    ///     // ...
    /// }
    /// ```
    ///
    /// The current `_read` implementation positions conformers for this transition.
    public protocol `Protocol`: ~Copyable {
        /// The element type of the input.
        ///
        /// > Note: Implicitly requires `Copyable` per SE-0427.
        /// > This is a language limitation, not a design choice.
        associatedtype Element

        /// Whether the input is empty.
        var isEmpty: Bool { get }

        /// The first element, if any.
        ///
        /// Returns `nil` if the input is empty. Does not consume the element.
        ///
        /// ## Implementation Note
        ///
        /// Conformers SHOULD use `_read` coroutine accessor to provide
        /// borrowing semantics, avoiding copies. This prepares for SE-0474's
        /// `yielding borrow` accessor when it becomes available.
        var first: Element? { get }

        // MARK: - Primitives

        /// Advances the cursor, returning the consumed element.
        ///
        /// - Returns: The consumed element.
        /// - Throws: ``Input/Stream/Error/empty`` if the input is empty.
        @discardableResult
        mutating func advance() throws(Input.Stream.Error) -> Element
    }
}

// MARK: - Typealias for Backwards Compatibility

extension Input {
    /// Alias for ``Input/Stream/Protocol``.
    ///
    /// Provided for ergonomic conformance declarations:
    /// ```swift
    /// extension MyType: Input.Streaming { ... }
    /// ```
    public typealias Streaming = Input.Stream.`Protocol`
}
