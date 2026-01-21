//
//  Input.Restore.swift
//  swift-input-primitives
//
//  Namespace and accessor operations for checkpoint restoration.
//

extension Input {
    /// Namespace for checkpoint restoration operations.
    ///
    /// Also serves as the phantom type tag for ``Facet`` discrimination.
    ///
    /// Contains:
    /// - ``Error``: Error type for restoration operations
    public enum Restore {}
}

// MARK: - Facet Property

extension Input.`Protocol` where Self: ~Copyable {
    /// Facet for checkpoint restoration operations.
    ///
    /// Provides checked restoration with typed errors:
    /// - `to(_:)` throws ``Input/Restore/Error/invalidCheckpoint`` for invalid checkpoints
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let checkpoint = input.checkpoint
    /// // ... consume elements ...
    /// try input.restore.to(checkpoint)
    /// ```
    @inlinable
    public var restore: Facet<Self, Input.Restore> {
        mutating _read {
            yield unsafe Facet(&self)
        }
    }
}

// MARK: - Facet Operations

extension Facet where Tag == Input.Restore, Base: Input.`Protocol` & ~Copyable {
    /// Restores the input to a previously saved checkpoint.
    ///
    /// - Parameter checkpoint: A checkpoint obtained from the input's
    ///   `checkpoint` property.
    /// - Throws: ``Input/Restore/Error/invalidCheckpoint`` if the checkpoint is
    ///   out of bounds or was not created from this input instance.
    @inlinable
    public func to(_ checkpoint: Base.Checkpoint) throws(Input.Restore.Error) {
        guard unsafe base.pointee.isValid(checkpoint) else {
            throw .invalidCheckpoint
        }
        unsafe base.pointee.setPosition(to: checkpoint)
    }

    /// Sets position directly without validation.
    ///
    /// - Precondition: `checkpoint` was created from this input instance
    ///   and represents a valid position.
    @inlinable
    public func to(__unchecked: Void, _ checkpoint: Base.Checkpoint) {
        unsafe base.pointee.setPosition(to: checkpoint)
    }
}
