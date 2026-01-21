//
//  Input.Access.Error.swift
//  swift-input-primitives
//
//  Error type for element access operations.
//

// MARK: - Hoisted Error Type (Module Level)
//
// Swift does not allow nested types inside generic types to be easily accessed.
// This error type is hoisted to module level and exposed via typealias to
// provide the expected Nest.Name API (Input.Access.Error).
//
// This is a documented exception per [API-ERR-009] due to Swift language
// limitations with generic nested types.
//
// Use the typealias form in your code:
// - Input.Access<Base>.Error

/// Hoisted implementation of ``Input/Access/Error``.
///
/// - Note: Use ``Input/Access/Error`` in your code, not this type directly.
public enum __InputAccessError: Swift.Error, Sendable, Equatable {
    /// Offset is out of bounds.
    ///
    /// Thrown by `element(at:)` when the offset is negative
    /// or exceeds the remaining element count.
    ///
    /// - Parameters:
    ///   - offset: The requested offset.
    ///   - count: The number of elements available.
    case outOfBounds(offset: Int, count: Int)
}

// MARK: - Typealias (Nest.Name API)

extension Input.Access {
    /// Errors for element access operations.
    ///
    /// Thrown by ``Input/Random`` access operations when the offset
    /// is out of bounds.
    ///
    /// ## Cases
    ///
    /// - ``outOfBounds(offset:count:)``: The offset is invalid.
    public typealias Error = __InputAccessError
}
