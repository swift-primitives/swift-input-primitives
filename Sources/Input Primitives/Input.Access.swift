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
    public struct Access<Base: Input.Random>: ~Copyable, ~Escapable {
        @usableFromInline
        let _base: UnsafePointer<Base>

        @inlinable
        @_lifetime(borrow base)
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

// MARK: - Prefix Comparison

extension Input.Access where Base.Element: Equatable {
    /// Checks if remaining elements start with the given prefix.
    ///
    /// - Parameter prefix: Collection to compare against.
    /// - Returns: `true` if remaining elements start with prefix.
    /// - Complexity: O(prefix.count) without allocation.
    @inlinable
    public func starts<Prefix: Collection>(with prefix: Prefix) -> Bool
    where Prefix.Element == Base.Element {
        guard prefix.count <= _base.pointee.count else { return false }
        for (offset, element) in prefix.enumerated() {
            if _base.pointee[offset: offset] != element { return false }
        }
        return true
    }

    /// Checks if the input starts with the given element.
    ///
    /// - Parameter element: Element to compare against.
    /// - Returns: `true` if remaining input starts with element.
    /// - Complexity: O(1)
    @inlinable
    public func starts(with element: Base.Element) -> Bool {
        !_base.pointee.isEmpty && _base.pointee[offset: 0] == element
    }
}
