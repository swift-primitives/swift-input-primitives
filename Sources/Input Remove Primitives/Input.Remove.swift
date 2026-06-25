//
//  Input.Remove.swift
//  swift-input-primitives
//
//  Namespace and accessor operations for element removal.
//

extension Input {
    /// Namespace for element removal operations.
    ///
    /// Also serves as the phantom type tag for ``Property``.``View`` discrimination.
    ///
    /// Contains:
    /// - ``Error``: Error type for removal operations
    public enum Remove {}
}

// MARK: - Property Accessor

extension Input.Streaming where Self: ~Copyable {
    /// Property view for element removal operations.
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
    public var remove: Property<Input.Remove, Self>.Inout {
        mutating _read {
            yield Property.Inout(&self)
        }
    }
}

// MARK: - Property Operations (Streaming)

extension Property.Inout where Tag == Input.Remove, Base: Input.Streaming & ~Copyable {
    /// Removes and returns the first element.
    ///
    /// - Returns: The first element.
    /// - Throws: ``Input/Remove/Error/empty`` if the input is empty.
    @inlinable
    @discardableResult
    public func first() throws(Input.Remove.Error<Base.Element>) -> Base.Element {
        do throws(Input.Stream.Error) {
            return try base.value.advance()
        } catch {
            throw .empty
        }
    }

    /// Advances cursor directly without validation.
    ///
    /// - Precondition: `!isEmpty`
    /// - Returns: The consumed element.
    ///
    /// - Warning: Undefined behavior if input is empty. Use `advance()` for safe access.
    @inlinable
    @discardableResult
    public func first(__unchecked: Void) -> Base.Element {
        // SAFETY: `__unchecked` variant requires the caller's precondition
        // `!isEmpty` to be upheld, so `advance()` cannot throw. We use do/catch
        // with a fatalError sentinel instead of `try!` to keep swift-format
        // happy; the error path is unreachable when the precondition is upheld.
        do throws(Input.Stream.Error) {
            return try base.value.advance()
        } catch {
            fatalError("first(__unchecked:) called on empty input — precondition violated")
        }
    }
}

// MARK: - Property Operations (Protocol - multi-element)

extension Property.Inout where Tag == Input.Remove, Base: Input.`Protocol` & ~Copyable {
    /// Removes and discards the first `count` elements.
    ///
    /// - Parameter count: The number of elements to remove.
    /// - Throws: ``Input/Remove/Error/insufficientElements(requested:available:)``
    ///   if `count` exceeds the remaining elements.
    @inlinable
    public func first(_ count: Index<Base.Element>.Count) throws(Input.Remove.Error<Base.Element>) {
        let available = base.value.count
        guard count <= available else {
            throw .insufficientElements(requested: count, available: available)
        }
        base.value.advance(by: count)
    }

    /// Advances cursor by count directly without validation.
    ///
    /// - Precondition: `count <= self.count`
    @inlinable
    public func first(__unchecked: Void, _ count: Index<Base.Element>.Count) {
        base.value.advance(by: count)
    }
}
