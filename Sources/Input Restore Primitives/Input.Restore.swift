//
//  Input.Restore.swift
//  swift-input-primitives
//
//  Namespace and accessor operations for checkpoint restoration.
//

extension Input {
    /// Namespace for checkpoint restoration operations.
    ///
    /// Also serves as the phantom type tag for ``Property``.``View`` discrimination.
    ///
    /// Contains:
    /// - ``Error``: Error type for restoration operations
    public enum Restore {}
}

// MARK: - Property Accessor

extension Input.`Protocol` where Self: ~Copyable {
    /// Property view for checkpoint restoration operations.
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
    public var restore: Property<Input.Restore, Self>.Inout {
        mutating _read {
            yield Property.Inout(&self)
        }
    }
}

// MARK: - Property Operations

extension Property.Inout where Tag == Input.Restore, Base: Input.`Protocol` & ~Copyable {
    /// Restores the input to a previously saved checkpoint.
    ///
    /// - Parameter checkpoint: A checkpoint obtained from the input's
    ///   `checkpoint` property.
    /// - Throws: ``Input/Restore/Error/invalidCheckpoint`` if the checkpoint is
    ///   out of bounds or was not created from this input instance.
    @inlinable
    public func to(_ checkpoint: Base.Checkpoint) throws(Input.Restore.Error) {
        guard base.value.isValid(checkpoint) else {
            throw .invalidCheckpoint
        }
        base.value.seek(to: checkpoint)
    }

    /// Sets position directly without validation.
    ///
    /// - Precondition: `checkpoint` was created from this input instance
    ///   and represents a valid position.
    @inlinable
    public func to(__unchecked: Void, _ checkpoint: Base.Checkpoint) {
        base.value.seek(to: checkpoint)
    }
}
