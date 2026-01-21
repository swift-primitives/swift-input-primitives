//
//  Input.Remove.Error.swift
//  swift-input-primitives
//
//  Error type for element removal operations.
//

// MARK: - Hoisted Error Type (Module Level)
//
// Swift does not allow nested types inside generic types to be easily accessed.
// This error type is hoisted to module level and exposed via typealias to
// provide the expected Nest.Name API (Input.Remove.Error).
//
// This is a documented exception per [API-ERR-009] due to Swift language
// limitations with generic nested types.
//
// Use the typealias form in your code:
// - Input.Remove<Base>.Error

/// Hoisted implementation of ``Input/Remove/Error``.
///
/// - Note: Use ``Input/Remove/Error`` in your code, not this type directly.
public enum __InputRemoveError: Swift.Error, Sendable, Equatable {
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
    case insufficientElements(requested: Int, available: Int)
}

// MARK: - Typealias (Nest.Name API)

extension Input.Remove where Base: ~Copyable {
    /// Errors for element removal operations.
    ///
    /// Thrown by ``Input/Streaming`` removal operations when the input
    /// cannot satisfy the request.
    ///
    /// ## Cases
    ///
    /// - ``empty``: The input is empty.
    /// - ``insufficientElements(requested:available:)``: Requested more elements than available.
    public typealias Error = __InputRemoveError
}
