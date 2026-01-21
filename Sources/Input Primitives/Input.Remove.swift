//
//  Input.Remove.swift
//  swift-input-primitives
//
//  Namespace and accessor operations for element removal.
//

extension Input {
    /// Namespace for element removal operations.
    ///
    /// Also serves as the phantom type tag for ``Accessor`` discrimination.
    ///
    /// Contains:
    /// - ``Error``: Error type for removal operations
    public enum Remove {}
}

// MARK: - Accessor Property

extension Input.Streaming where Self: ~Copyable {
    /// Accessor for element removal operations.
    ///
    /// Provides checked removal with typed errors:
    /// - `first()` throws ``Input/Remove/Error/empty`` when input is exhausted
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let element = try input.remove.first()
    /// ```
    @inlinable
    public var remove: Accessor<Self, Input.Remove> {
        mutating _read {
            yield unsafe Accessor(&self)
        }
    }
}

// MARK: - Accessor Operations (Streaming)

extension Accessor where Tag == Input.Remove, Base: Input.Streaming & ~Copyable {
    /// Removes and returns the first element.
    ///
    /// - Returns: The first element.
    /// - Throws: ``Input/Remove/Error/empty`` if the input is empty.
    @inlinable
    @discardableResult
    public func first() throws(Input.Remove.Error) -> Base.Element {
        guard unsafe !base.pointee.isEmpty else {
            throw .empty
        }
        return unsafe base.pointee.advance()
    }

    /// Advances cursor directly without validation.
    ///
    /// - Precondition: `!isEmpty`
    /// - Returns: The consumed element.
    @inlinable
    @discardableResult
    public func first(__unchecked: Void) -> Base.Element {
        unsafe base.pointee.advance()
    }
}

// MARK: - Accessor Operations (Protocol - multi-element)

extension Accessor where Tag == Input.Remove, Base: Input.`Protocol` & ~Copyable {
    /// Removes and discards the first `count` elements.
    ///
    /// - Parameter count: The number of elements to remove.
    /// - Throws: ``Input/Remove/Error/insufficientElements(requested:available:)``
    ///   if `count` exceeds the remaining elements.
    @inlinable
    public func first(_ count: Int) throws(Input.Remove.Error) {
        let available = unsafe base.pointee.count
        guard count >= 0 && count <= available else {
            throw .insufficientElements(requested: count, available: available)
        }
        unsafe base.pointee.advance(by: count)
    }

    /// Advances cursor by count directly without validation.
    ///
    /// - Precondition: `count >= 0 && count <= self.count`
    @inlinable
    public func first(__unchecked: Void, _ count: Int) {
        unsafe base.pointee.advance(by: count)
    }
}
