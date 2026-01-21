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
    /// ## Totality
    ///
    /// All operations are total per [API-IMPL-003]:
    /// - `restore(to:)` throws for invalid checkpoints
    /// - `removeFirst(_:)` throws when requesting more elements than available
    ///
    /// For unchecked access in performance-critical paths, use the
    /// `__unchecked` variants.
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
    /// let a = try input.removeFirst()  // 1
    /// let b = try input.removeFirst()  // 2
    ///
    /// // Failed, restore position
    /// try input.restore(to: checkpoint)
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
        /// - Throws: ``Input/Error/invalidCheckpoint`` if the checkpoint is
        ///   out of bounds or was not created from this input instance.
        mutating func restore(to checkpoint: Checkpoint) throws(Input.Error)

        /// Removes and discards the first `n` elements.
        ///
        /// - Parameter n: The number of elements to skip.
        /// - Throws: ``Input/Error/insufficientElements(requested:available:)``
        ///   if `n > count`.
        mutating func removeFirst(_ n: Int) throws(Input.Error)

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

// MARK: - Unchecked Access

extension Input.`Protocol` {
    /// Restores to checkpoint without validation.
    ///
    /// Use in performance-critical paths where the checkpoint is known valid.
    ///
    /// - Precondition: `checkpoint` was created from this input instance
    ///   and represents a valid position.
    @inlinable
    public mutating func restore(__unchecked: Void, to checkpoint: Checkpoint) {
        try! restore(to: checkpoint)
    }

    /// Removes `n` elements without bounds checking.
    ///
    /// Use in performance-critical paths where `n <= count` is known.
    ///
    /// - Precondition: `n >= 0` and `n <= count`.
    @inlinable
    public mutating func removeFirst(__unchecked: Void, _ n: Int) {
        try! removeFirst(n)
    }
}
