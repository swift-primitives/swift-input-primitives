//
//  Input.Error.swift
//  swift-input-primitives
//
//  Error type for input operations.
//

extension Input {
    /// Errors for input operations.
    ///
    /// Provides typed error information for partial input operations,
    /// enabling callers to handle failures with full context.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input = Input.Buffer([1, 2, 3])
    /// do {
    ///     try input.removeFirst(10)
    /// } catch .insufficientElements(let requested, let available) {
    ///     print("Wanted \(requested), had \(available)")
    /// }
    /// ```
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input is empty.
        ///
        /// Thrown by `removeFirst()` when no elements remain.
        case empty

        /// Requested more elements than available.
        ///
        /// - Parameters:
        ///   - requested: The number of elements requested.
        ///   - available: The number of elements actually available.
        case insufficientElements(requested: Int, available: Int)

        /// Checkpoint is not valid for this input.
        ///
        /// Thrown by `restore(to:)` when the checkpoint is out of bounds
        /// or was not created from this input instance.
        case invalidCheckpoint
    }
}
