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
    /// ## Usage
    ///
    /// ```swift
    /// var input = Input.Buffer([1, 2, 3, 4, 5])
    /// let checkpoint = input.checkpoint
    ///
    /// // Try to match something
    /// let a = try input.remove.first()  // 1
    /// let b = try input.remove.first()  // 2
    ///
    /// // Failed, restore position
    /// try input.restore.to(checkpoint)
    /// assert(input.first == 1)  // Back at start
    /// ```
    ///
    /// ## Totality
    ///
    /// All operations are total per [API-IMPL-003]:
    /// - `restore.to(_:)` throws for invalid checkpoints
    /// - `remove.first(_:)` throws when requesting more elements than available
    ///
    /// ## Protocol Hierarchy
    ///
    /// ```
    /// Input.Streaming      ← minimal, forward-only (isEmpty, first, remove)
    ///       ↑
    /// Input.Protocol       ← adds checkpoint/restore for backtracking
    ///       ↑
    /// Input.Access.Random  ← adds subscript(offset:), access.starts(with:)
    /// ```
    ///
    /// ## Capability Factoring
    ///
    /// This protocol defines the core checkpoint contract without requiring
    /// `Copyable`. The ``remaining`` property is available only when
    /// `Self: Copyable`, as it returns a copy of the cursor.
    ///
    /// This factoring allows move-only cursor types (e.g., linear cursors
    /// over unique storage) to conform while preserving checkpoint/restore
    /// semantics.
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
    public protocol `Protocol`<Element>: Streaming, ~Copyable {
        /// The checkpoint type for position-based backtracking.
        ///
        /// Must be `Sendable` for concurrent parsing and `Comparable`
        /// for range-based validation.
        ///
        /// For ``Input/Buffer``, this is `Index<Element>` from index-primitives.
        /// For ``Input/Slice``, this is `Base.Index`.
        associatedtype Checkpoint: Sendable & Comparable

        /// The number of elements remaining.
        var count: Index<Element>.Count { get }

        /// Creates a checkpoint at the current position.
        ///
        /// The checkpoint can be used with `restore.to(_:)` to backtrack.
        /// This must be O(1) and should not allocate.
        var checkpoint: Checkpoint { get }

        /// The range of valid checkpoint positions.
        ///
        /// Used by the default ``__isValidCheckpoint(_:)`` implementation.
        /// Conformers provide bounds; validation logic is centralized.
        var checkpointRange: ClosedRange<Checkpoint> { get }

        // MARK: - Primitives

        /// Sets the cursor position to a checkpoint.
        ///
        /// - Precondition: `checkpointRange.contains(checkpoint)` is true.
        ///
        /// > Note: Conformance primitive. Use `restore.to(_:)` for validated API.
        mutating func setPosition(to checkpoint: Checkpoint)

        /// Advances the cursor by the given count.
        ///
        /// - Precondition: `count <= self.count`
        ///
        /// > Note: Conformance primitive. Use `remove.first(_:)` for validated API.
        mutating func advance(by count: Index<Element>.Count)
    }
}

// MARK: - Default Checkpoint Validation

extension Input.`Protocol` where Self: ~Copyable {
    /// Checks if a checkpoint is valid for this input.
    ///
    /// Default implementation uses ``checkpointRange`` for validation.
    ///
    /// - Parameter checkpoint: The checkpoint to validate.
    /// - Returns: `true` if the checkpoint can be restored to.
    @inlinable
    public func isValid(_ checkpoint: Checkpoint) -> Bool {
        checkpointRange.contains(checkpoint)
    }
}

// MARK: - Copyable Capability (remaining)

extension Input.`Protocol` where Self: Copyable {
    /// The remaining input as a copy of the cursor.
    ///
    /// Returns a copy of `self`, preserving the current position.
    /// Available only when `Self: Copyable`.
    ///
    /// For composability with APIs that consume input values.
    ///
    /// - Complexity: O(1) for cursor types (copies position, not elements).
    @inlinable
    public var remaining: Self {
        self
    }
}

