//
//  Input.Restore.swift
//  swift-input-primitives
//
//  Accessor for checkpoint restoration operations.
//

extension Input {
    /// Accessor for checkpoint restoration operations on input types.
    ///
    /// Provides the `to(_:)` operation for backtracking to a previously
    /// saved checkpoint. Accessed via the `restore` property on input types.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var input = Input.Buffer([1, 2, 3, 4, 5])
    /// let checkpoint = input.checkpoint
    ///
    /// _ = try input.remove.first()
    /// _ = try input.remove.first()
    /// // input.first == 3
    ///
    /// try input.restore.to(checkpoint)
    /// // input.first == 1
    /// ```
    ///
    /// ## Totality
    ///
    /// All operations use typed throws per [API-ERR-001]:
    /// - `to(_:)` throws ``Error/invalidCheckpoint`` when the checkpoint
    ///   is out of bounds or was not created from this input instance
    @safe
    public struct Restore<Base: Input.`Protocol`>: ~Copyable, ~Escapable {
        @usableFromInline
        let _base: UnsafeMutablePointer<Base>

        @inlinable
        @_lifetime(borrow base)
        init(_ base: UnsafeMutablePointer<Base>) {
            unsafe _base = base
        }

        /// Restores the input to a previously saved checkpoint.
        ///
        /// - Parameter checkpoint: A checkpoint obtained from the input's
        ///   `checkpoint` property.
        /// - Throws: ``Error/invalidCheckpoint`` if the checkpoint is
        ///   out of bounds or was not created from this input instance.
        @inlinable
        public func to(_ checkpoint: Base.Checkpoint) throws(Input.Restore<Base>.Error) {
            guard unsafe _base.pointee.__isValidCheckpoint(checkpoint) else {
                throw .invalidCheckpoint
            }
            unsafe _base.pointee.__restoreUnchecked(to: checkpoint)
        }
    }
}

// MARK: - Unchecked access

extension Input.Restore {
    /// Restores to checkpoint without validation.
    ///
    /// - Precondition: `checkpoint` was created from this input instance
    ///   and represents a valid position.
    @inlinable
    public func to(__unchecked: Void, _ checkpoint: Base.Checkpoint) {
        unsafe _base.pointee.__restoreUnchecked(to: checkpoint)
    }
}
