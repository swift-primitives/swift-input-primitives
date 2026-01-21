//
//  Input.Restore.Error.swift
//  swift-input-primitives
//
//  Error type for checkpoint restoration operations.
//

// MARK: - Hoisted Error Type (Module Level)
//
// Swift does not allow nested types inside generic types to be easily accessed.
// This error type is hoisted to module level and exposed via typealias to
// provide the expected Nest.Name API (Input.Restore.Error).
//
// This is a documented exception per [API-ERR-009] due to Swift language
// limitations with generic nested types.
//
// Use the typealias form in your code:
// - Input.Restore<Base>.Error

/// Hoisted implementation of ``Input/Restore/Error``.
///
/// - Note: Use ``Input/Restore/Error`` in your code, not this type directly.
public enum __InputRestoreError: Swift.Error, Sendable, Equatable {
    /// The checkpoint is invalid.
    ///
    /// Thrown by `to(_:)` when the checkpoint is out of bounds
    /// or was not created from this input instance.
    case invalidCheckpoint
}

// MARK: - Typealias (Nest.Name API)

extension Input.Restore where Base: ~Copyable {
    /// Errors for checkpoint restoration operations.
    ///
    /// Thrown by ``Input/Protocol`` restoration operations when the
    /// checkpoint is invalid.
    ///
    /// ## Cases
    ///
    /// - ``invalidCheckpoint``: The checkpoint is out of bounds or invalid.
    public typealias Error = __InputRestoreError
}
