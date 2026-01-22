//
//  Input.Access.Random.swift
//  swift-input-primitives
//
//  Protocol refinement for random access within remaining input.
//

// MARK: - Namespace

extension Input {
    /// Namespace for random access types and operations.
    ///
    /// Also serves as the phantom type tag for ``Property``.``View`` discrimination.
    ///
    /// Contains:
    /// - ``Random``: Protocol for random access capability
    /// - ``Error``: Error type for access operations
    public enum Access {
        /// Hoisted implementation of ``Input/Access/Random``.
        ///
        /// A type that provides random access within the remaining input.
        /// Extends ``Input/Protocol`` with offset-based subscript and prefix
        /// comparison, enabling efficient lookahead without consumption.
        ///
        /// - Note: Use ``Input/Access/Random`` in your code, not this type directly.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// let input = Input.Buffer([0x48, 0x65, 0x6C, 0x6C, 0x6F])
        ///
        /// // Unchecked offset access (stdlib subscript pattern)
        /// assert(input[offset: 0] == 0x48)
        /// assert(input[offset: 4] == 0x6F)
        ///
        /// // Checked access via accessor
        /// let third = try input.access.element(at: 2)
        ///
        /// // Prefix check without consumption (via accessor)
        /// assert(input.access.starts(with: [0x48, 0x65]))  // "He"
        /// ```
        ///
        /// ## Totality
        ///
        /// - `subscript(offset:)` is unchecked per stdlib Collection subscript convention
        /// - `access.element(at:)` provides total access with typed throws
        ///
        /// ## Protocol Hierarchy
        ///
        /// ```
        /// Input.Streaming      ← minimal, forward-only
        ///       ↑
        /// Input.Protocol       ← checkpoint/restore
        ///       ↑
        /// Input.Access.Random  ← subscript(offset:), access.starts(with:)
        /// ```
        ///
        /// ## Performance Requirements
        ///
        /// - ``subscript(offset:)`` must be O(1) for conforming types
        /// - `access.starts(with:)` must be O(prefix.count) without allocation
        public protocol Random<Element>: Input.`Protocol`, ~Copyable {
            /// Accesses the element at the given offset from current position.
            ///
            /// This is unchecked per stdlib Collection subscript convention.
            /// For total access, use `access.element(at:)`.
            ///
            /// - Parameter offset: Offset from current position (0-indexed).
            /// - Precondition: `offset >= 0` and `offset < count`.
            /// - Complexity: O(1)
            subscript(offset offset: Int) -> Element { get }
        }
    }
}

// MARK: - Property Accessor

extension Input.Access.Random where Self: ~Copyable {
    /// Property view for random element access operations.
    ///
    /// Provides checked access with typed errors:
    /// - `element(at:)` throws ``Input/Access/Error/outOfBounds(offset:count:)``
    ///   for invalid offsets
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let third = try input.access.element(at: 2)
    /// ```
    @inlinable
    public var access: Property<Input.Access, Self>.View {
        mutating _read {
            yield unsafe Property.View(&self)
        }
    }
}

// MARK: - Property Operations

extension Property.View where Tag == Input.Access, Base: Input.Access.Random & ~Copyable {
    /// Accesses the element at the given offset.
    ///
    /// - Parameter offset: Offset from current position (0-indexed).
    /// - Returns: The element at the offset.
    /// - Throws: ``Input/Access/Error/outOfBounds(offset:count:)`` if the offset
    ///   is negative or exceeds the remaining element count.
    @inlinable
    public func element(at offset: Int) throws(Input.Access.Error) -> Base.Element {
        let count = unsafe base.pointee.count
        guard offset >= 0 && offset < count else {
            throw .outOfBounds(offset: offset, count: count)
        }
        return unsafe base.pointee[offset: offset]
    }
}

extension Property.View where Tag == Input.Access, Base: Input.Access.Random & ~Copyable, Base.Element: Equatable {
    /// Checks if remaining elements start with the given prefix.
    ///
    /// - Parameter prefix: Collection to compare against.
    /// - Returns: `true` if remaining elements start with prefix.
    /// - Complexity: O(*n*) where *n* is the length of `prefix`. Note that
    ///   `prefix.count` is also called, which is O(1) for `RandomAccessCollection`
    ///   but O(*n*) for other collections.
    @inlinable
    public func starts<Prefix: Swift.Collection>(with prefix: Prefix) -> Bool
    where Prefix.Element == Base.Element {
        guard unsafe prefix.count <= base.pointee.count else { return false }
        for (offset, element) in prefix.enumerated() {
            if unsafe base.pointee[offset: offset] != element { return false }
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
        unsafe !base.pointee.isEmpty && base.pointee[offset: 0] == element
    }
}
