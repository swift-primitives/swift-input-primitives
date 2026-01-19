//
//  Input.Protocol.swift
//  swift-input-primitives
//
//  Protocol for input types enabling zero-copy parsing with backtracking.
//

extension Input {
    /// A type that can be used as input with backtracking support.
    ///
    /// `Protocol` refines ``Input/Streaming`` by adding checkpoint-based backtracking,
    /// enabling parser combinators like `OneOf`, `Peek`, and `Not` to try
    /// alternatives and restore position on failure.
    ///
    /// ## Protocol Hierarchy
    ///
    /// ```
    /// Input.Streaming      ← minimal, forward-only (isEmpty, first, removeFirst)
    ///       ↑
    /// Input.Protocol       ← adds checkpoint/restore for backtracking
    ///       ↑
    /// Input.Access.Random  ← adds subscript(offset:), starts(with:)
    /// ```
    ///
    /// ## Abstracts Over
    ///
    /// - ``Input/Slice`` for zero-copy collection cursors
    /// - ``Input/Buffer`` for owned buffer cursors
    ///
    /// ## Zero-Copy Guarantee
    ///
    /// All operations should be O(1) and non-allocating for conforming types.
    /// The protocol does not require random access - only forward iteration
    /// with the ability to save and restore positions.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input = Input.Buffer([1, 2, 3, 4, 5])
    /// let checkpoint = input.checkpoint
    ///
    /// // Try to match something
    /// let a = input.removeFirst()  // 1
    /// let b = input.removeFirst()  // 2
    ///
    /// // Failed, restore position
    /// input.restore(to: checkpoint)
    /// assert(input.first == 1)  // Back at start
    /// ```
    public protocol `Protocol`<Element>: Streaming where Self: Copyable {
        /// The checkpoint type for position-based backtracking.
        ///
        /// Typically a lightweight value like `Int` or an index type.
        /// Must be `Sendable` for use in concurrent parsing contexts.
        associatedtype Checkpoint: Sendable

        /// The number of elements remaining.
        var count: Int { get }

        /// Creates a checkpoint at the current position.
        ///
        /// The checkpoint can be used with ``restore(to:)`` to backtrack.
        /// This must be O(1) and should not allocate.
        var checkpoint: Checkpoint { get }

        /// Restores the input to a previously saved checkpoint.
        ///
        /// - Parameter checkpoint: A checkpoint obtained from ``checkpoint``.
        /// - Precondition: The checkpoint was created from this input instance.
        mutating func restore(to checkpoint: Checkpoint)

        /// Removes and discards the first `n` elements.
        ///
        /// - Parameter n: The number of elements to skip.
        /// - Precondition: `n >= 0` and `n <= count`.
        mutating func removeFirst(_ n: Int)

        /// The remaining input as the same type (for composability).
        ///
        /// Default implementation returns `self`. Override for types
        /// that need conversion (e.g., Array → ArraySlice).
        var remaining: Self { get }
    }
}

// MARK: - Default Implementations

extension Input.`Protocol` {
    /// Default remaining implementation returns self.
    @inlinable
    public var remaining: Self {
        self
    }
}
