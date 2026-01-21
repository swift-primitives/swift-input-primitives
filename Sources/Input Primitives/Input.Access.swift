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
    @safe
    public struct Access<Base: Input.Random & ~Copyable>: ~Copyable, ~Escapable {
        @usableFromInline
        let _base: UnsafePointer<Base>

        @inlinable
        @_lifetime(borrow base)
        init(_ base: UnsafePointer<Base>) {
            unsafe _base = base
        }

        /// Accesses the element at the given offset.
        ///
        /// - Parameter offset: Offset from current position (0-indexed).
        /// - Returns: The element at the offset.
        /// - Throws: ``Error/outOfBounds(offset:count:)`` if the offset
        ///   is negative or exceeds the remaining element count.
        @inlinable
        public func element(at offset: Int) throws(Input.Access<Base>.Error) -> Base.Element {
            let count = unsafe _base.pointee.count
            guard offset >= 0 && offset < count else {
                throw .outOfBounds(offset: offset, count: count)
            }
            return unsafe _base.pointee[offset: offset]
        }
    }
}

// MARK: - Prefix Comparison

extension Input.Access where Base: ~Copyable, Base.Element: Equatable {
    /// Checks if remaining elements start with the given prefix.
    ///
    /// - Parameter prefix: Collection to compare against.
    /// - Returns: `true` if remaining elements start with prefix.
    /// - Complexity: O(*n*) where *n* is the length of `prefix`. Note that
    ///   `prefix.count` is also called, which is O(1) for `RandomAccessCollection`
    ///   but O(*n*) for other collections.
    @inlinable
    public func starts<Prefix: Collection>(with prefix: Prefix) -> Bool
    where Prefix.Element == Base.Element {
        guard unsafe prefix.count <= _base.pointee.count else { return false }
        for (offset, element) in prefix.enumerated() {
            if unsafe _base.pointee[offset: offset] != element { return false }
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
        unsafe !_base.pointee.isEmpty && _base.pointee[offset: 0] == element
    }
}
