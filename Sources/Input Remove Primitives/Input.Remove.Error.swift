//
//  Input.Remove.Error.swift
//  swift-input-primitives
//
//  Error type for element removal operations.
//

extension Input.Remove {
    /// Errors for element removal operations.
    ///
    /// Thrown by removal operations when the input cannot satisfy the request.
    ///
    /// ## Cases
    ///
    /// - ``empty``: The input is empty.
    /// - ``insufficientElements(requested:available:)``: Requested more elements than available.
    public enum Error<Element: ~Copyable>: Swift.Error, Sendable, Equatable {
        /// The input is empty.
        ///
        /// Thrown by `first()` when no elements remain.
        case empty

        /// Requested more elements than available.
        ///
        /// Thrown by `first(_:)` when the count exceeds remaining elements.
        ///
        /// - Parameters:
        ///   - requested: The number of elements requested.
        ///   - available: The number of elements actually available.
        case insufficientElements(requested: Index<Element>.Count, available: Index<Element>.Count)
    }
}
