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
    public protocol `Protocol`: ~Copyable {
        /// The element type of the input.
        associatedtype Element

        /// Whether the input is empty.
        var isEmpty: Bool { get }

        /// The first element, if any.
        ///
        /// Returns `nil` if the input is empty. Does not consume the element.
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
