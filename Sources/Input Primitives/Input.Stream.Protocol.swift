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
    /// - Consume elements via `advance()`
    ///
    /// The core streaming contract is `isEmpty` + `advance()`. The `first` property
    /// (peek without consuming) lives on concrete conformers rather than in the protocol,
    /// because `_read` cannot yield `~Copyable` values through `Optional`.
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
    /// - `isEmpty` is inherently total
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
    /// ## Future Direction
    ///
    /// [SE-0474](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0474-yielding-accessors.md)
    /// (`yielding borrow`) would allow `first` to be restored as a protocol requirement:
    ///
    /// ```swift
    /// // Future API when SE-0474 is available:
    /// var first: Element? { yielding borrow }
    /// ```
    ///
    /// Until then, `first` is provided directly by concrete conformers
    /// (``Input/Buffer``, ``Input/Slice``) for Copyable element types.
    public protocol `Protocol`: ~Copyable {
        /// The element type of the input.
        associatedtype Element: ~Copyable

        /// Whether the input is empty.
        var isEmpty: Bool { get }

        // MARK: - Primitives

        /// Advances the cursor, returning the consumed element.
        ///
        /// - Returns: The consumed element.
        /// - Throws: ``Input/Stream/Error/empty`` if the input is empty.
        @discardableResult
        mutating func advance() throws(Input.Stream.Error) -> Element
    }
}

// MARK: - Convenience

extension Input.Stream.`Protocol` where Self: ~Copyable {
    /// Consumes and returns the next element, or `nil` if empty.
    ///
    /// Convenience that combines `isEmpty` and `advance()` into a single call.
    @inlinable
    public mutating func next() -> Element? {
        guard !isEmpty else { return nil }
        return try! advance()
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
