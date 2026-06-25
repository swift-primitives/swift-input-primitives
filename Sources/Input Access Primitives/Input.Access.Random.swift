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
    public enum Access {}
}

// MARK: - Random Protocol

extension Input.Access {
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
        subscript(offset offset: Index<Element>.Offset) -> Element { get }
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
    public var access: Property<Input.Access, Self>.Inout {
        mutating _read {
            yield Property.Inout(&self)
        }
    }
}

// MARK: - Property Operations

extension Property.Inout where Tag == Input.Access, Base: Input.Access.Random & ~Copyable, Base.Element: Copyable {
    /// Accesses the element at the given offset.
    ///
    /// - Parameter offset: Offset from current position (0-indexed).
    /// - Returns: The element at the offset.
    /// - Throws: ``Input/Access/Error/outOfBounds(offset:count:)`` if the offset
    ///   is negative or exceeds the remaining element count.
    @inlinable
    public func element(
        at offset: Index<Base.Element>.Offset
    ) throws(Input.Access.Error<Base.Element>) -> Base.Element {
        let count = base.value.count
        guard offset >= .zero && offset < count else {
            throw .outOfBounds(offset: offset, count: count)
        }
        return base.value[offset: offset]
    }
}

extension Property.Inout where Tag == Input.Access, Base: Input.Access.Random & ~Copyable, Base.Element: Equatable {
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
        // SAFETY: Swift.Collection.count is always non-negative, so the
        // conversion to non-negative Cardinal-backed Count cannot throw.
        // We use do/catch with a `.zero` sentinel instead of `try!` to keep
        // swift-format happy; the error path is unreachable.
        let prefixCount: Index<Base.Element>.Count
        do throws(Cardinal.Error) {
            prefixCount = try Index<Base.Element>.Count(prefix.count)
        } catch {
            prefixCount = .zero
        }
        guard prefixCount <= base.value.count else { return false }
        for (offset, element) in prefix.enumerated() {
            if base.value[offset: Index<Base.Element>.Offset(offset)] != element { return false }
        }
        return true
    }

    // SE-0499: Swift.Equatable no longer implies Copyable in Swift 6.4.
    // The borrowing parameter lets this work for ~Copyable Equatable elements.
    #if compiler(>=6.4)
        /// Checks if the input starts with the given element.
        ///
        /// - Parameter element: Element to compare against.
        /// - Returns: `true` if remaining input starts with element.
        /// - Complexity: O(1)
        @inlinable
        public func starts(with element: borrowing Base.Element) -> Bool {
            !base.value.isEmpty && base.value[offset: Index<Base.Element>.Offset(0)] == element
        }
    #else
        /// Checks if the input starts with the given element.
        ///
        /// - Parameter element: Element to compare against.
        /// - Returns: `true` if remaining input starts with element.
        /// - Complexity: O(1)
        @inlinable
        public func starts(with element: Base.Element) -> Bool {
            !base.value.isEmpty && base.value[offset: Index<Base.Element>.Offset(0)] == element
        }
    #endif
}
