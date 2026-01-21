//
//  Input.Restore.Error.swift
//  swift-input-primitives
//
//  Error type for checkpoint restoration operations.
//

extension Input.Restore {
    /// Errors for checkpoint restoration operations.
    ///
    /// Thrown by restoration operations when the checkpoint is invalid.
    ///
    /// ## Cases
    ///
    /// - ``invalidCheckpoint``: The checkpoint is out of bounds or invalid.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The checkpoint is invalid.
        ///
        /// Thrown by `to(_:)` when the checkpoint is out of bounds
        /// or was not created from this input instance.
        case invalidCheckpoint
    }
}
