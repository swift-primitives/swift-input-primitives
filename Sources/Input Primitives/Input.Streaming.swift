//
//  Input.Streaming.swift
//  swift-input-primitives
//
//  Base protocol for streaming (non-backtracking) input sources.
//

extension Input {
    /// A type that can be used as streaming input.
    ///
    /// `Streaming` represents the minimal interface for forward-only input:
    /// - Check for end of input (`isEmpty`)
    /// - Peek at next element (`first`)
    /// - Consume elements via `remove` accessor
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
    ///     let element = try input.remove.first()
    ///     process(element)
    /// }
    /// ```
    ///
    /// ## Totality
    ///
    /// All operations are total per [API-IMPL-003]:
    /// - `isEmpty` and `first` are inherently total
    /// - `remove.first()` uses typed throws via ``Input/Remove/Error``
    ///
    /// ## Protocol Hierarchy
    ///
    /// ```
    /// Input.Streaming  ← minimal, forward-only
    ///       ↑
    /// Input.Protocol   ← adds checkpoint/restore for backtracking
    ///       ↑
    /// Input.Random     ← adds subscript(offset:), access.starts(with:)
    /// ```
    public protocol Streaming: ~Copyable {
        /// The element type of the input.
        associatedtype Element

        /// Whether the input is empty.
        var isEmpty: Bool { get }

        /// The first element, if any.
        ///
        /// Returns `nil` if the input is empty. Does not consume the element.
        var first: Element? { get }

        // MARK: - Unchecked Primitives

        /// Removes and returns the first element without checking.
        ///
        /// - Precondition: `!isEmpty`
        /// - Returns: The first element.
        ///
        /// > Note: This is an implementation primitive. Use `remove.first()`
        /// > for the checked public API.
        @discardableResult
        mutating func __removeFirstUnchecked() -> Element
    }
}

// MARK: - Remove Accessor

extension Input.Streaming where Self: ~Copyable {
    /// Accessor for element removal operations.
    ///
    /// Provides checked removal with typed errors:
    /// - `first()` throws ``Input/Remove/Error/empty`` when input is exhausted
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let element = try input.remove.first()
    /// ```
    @inlinable
    public var remove: Input.Remove<Self> {
        mutating _read {
            yield unsafe Input.Remove(&self)
        }
    }
}
