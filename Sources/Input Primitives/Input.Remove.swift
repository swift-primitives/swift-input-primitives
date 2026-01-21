//
//  Input.Remove.swift
//  swift-input-primitives
//
//  Accessor for element removal operations.
//

extension Input {
    /// Accessor for element removal operations on input types.
    ///
    /// Provides the `first()` operation for consuming elements from the front
    /// of an input source. Accessed via the `remove` property on input types.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var input = Input.Buffer([1, 2, 3, 4, 5])
    ///
    /// // Remove single element
    /// let first = try input.remove.first()
    ///
    /// // Remove multiple elements
    /// try input.remove.first(3)
    /// ```
    ///
    /// ## Totality
    ///
    /// All operations use typed throws per [API-ERR-001]:
    /// - `first()` throws ``Error/empty`` when input is exhausted
    /// - `first(_:)` throws ``Error/insufficientElements(requested:available:)``
    ///   when requesting more elements than available
    public struct Remove<Base: Input.Streaming>: ~Copyable, ~Escapable {
        @usableFromInline
        let _base: UnsafeMutablePointer<Base>

        @inlinable
        @_lifetime(borrow base)
        init(_ base: UnsafeMutablePointer<Base>) {
            _base = base
        }

        /// Removes and returns the first element.
        ///
        /// - Returns: The first element.
        /// - Throws: ``Error/empty`` if the input is empty.
        @inlinable
        @discardableResult
        public func first() throws(__InputRemoveError) -> Base.Element {
            guard !_base.pointee.isEmpty else {
                throw .empty
            }
            return _base.pointee.__removeFirstUnchecked()
        }
    }
}

// MARK: - Multi-element removal (requires Input.Protocol)

extension Input.Remove where Base: Input.`Protocol` {
    /// Removes and discards the first `count` elements.
    ///
    /// - Parameter count: The number of elements to remove.
    /// - Throws: ``Error/insufficientElements(requested:available:)``
    ///   if `count` exceeds the remaining elements.
    @inlinable
    public func first(_ count: Int) throws(__InputRemoveError) {
        let available = _base.pointee.count
        guard count >= 0 && count <= available else {
            throw .insufficientElements(requested: count, available: available)
        }
        _base.pointee.__removeFirstUnchecked(count)
    }
}

// MARK: - Unchecked access

extension Input.Remove {
    /// Removes and returns the first element without checking.
    ///
    /// - Precondition: `!isEmpty`
    /// - Returns: The first element.
    @inlinable
    @discardableResult
    public func first(__unchecked: Void) -> Base.Element {
        _base.pointee.__removeFirstUnchecked()
    }
}

extension Input.Remove where Base: Input.`Protocol` {
    /// Removes `count` elements without checking.
    ///
    /// - Precondition: `count >= 0 && count <= self.count`
    @inlinable
    public func first(__unchecked: Void, _ count: Int) {
        _base.pointee.__removeFirstUnchecked(count)
    }
}
