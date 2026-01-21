//
//  Input.Access.swift
//  swift-input-primitives
//
//  Accessor for random element access operations.
//

extension Input {
    /// Accessor for random element access operations on input types.
    ///
    /// Provides the `element(at:)` operation for checked random access.
    /// Accessed via the `access` property on input types.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let input = Input.Buffer([1, 2, 3, 4, 5])
    /// let third = try input.access.element(at: 2)
    /// ```
    ///
    /// ## Totality
    ///
    /// All operations use typed throws per [API-ERR-001]:
    /// - `element(at:)` throws ``Error/outOfBounds(offset:count:)``
    ///   when the offset is invalid
    public struct Access<Base: Input.Random> {
        @usableFromInline
        let _base: UnsafePointer<Base>

        @inlinable
        init(_ base: UnsafePointer<Base>) {
            _base = base
        }

        /// Accesses the element at the given offset.
        ///
        /// - Parameter offset: Offset from current position (0-indexed).
        /// - Returns: The element at the offset.
        /// - Throws: ``Error/outOfBounds(offset:count:)`` if the offset
        ///   is negative or exceeds the remaining element count.
        @inlinable
        public func element(at offset: Int) throws(__InputAccessError) -> Base.Element {
            let count = _base.pointee.count
            guard offset >= 0 && offset < count else {
                throw .outOfBounds(offset: offset, count: count)
            }
            return _base.pointee[offset: offset]
        }
    }
}

extension Input.Access {
    public typealias Random = Input.Random
}
