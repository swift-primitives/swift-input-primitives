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
    /// - Consume next element (`removeFirst()`)
    ///
    /// Unlike ``Input/Protocol``, this protocol does not require checkpointing
    /// or backtracking support, making it suitable for:
    /// - Network streams (where bytes cannot be re-read)
    /// - Large file parsing (where buffering is expensive)
    /// - Committed-choice parsing (where backtracking is not needed)
    ///
    /// ## Protocol Hierarchy
    ///
    /// ```
    /// Input.Streaming      ← minimal, forward-only
    ///       ↑
    /// Input.Protocol       ← adds checkpoint/restore for backtracking
    ///       ↑
    /// Input.Access.Random  ← adds subscript(offset:), starts(with:)
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

        /// Removes and returns the first element.
        ///
        /// - Precondition: `!isEmpty`
        /// - Returns: The first element.
        @discardableResult
        mutating func removeFirst() -> Element
    }
}

// MARK: - Total Consumption

extension Input.Streaming {
    /// Removes and returns the first element, or `nil` if the input is empty.
    ///
    /// This is the total variant of ``removeFirst()``.
    @inlinable
    public mutating func popFirst() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
}
