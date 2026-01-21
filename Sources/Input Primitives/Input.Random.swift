//
//  Input.Random.swift
//  swift-input-primitives
//
//  Protocol refinement for random access within remaining input.
//

extension Input {
    /// A type that provides random access within the remaining input.
    ///
    /// Extends ``Input/Protocol`` with offset-based subscript and prefix
    /// comparison, enabling efficient lookahead without consumption.
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
    /// // Prefix check without consumption
    /// assert(input.starts(with: [0x48, 0x65]))  // "He"
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
    /// Input.Streaming  ← minimal, forward-only
    ///       ↑
    /// Input.Protocol   ← checkpoint/restore
    ///       ↑
    /// Input.Random     ← subscript(offset:), starts(with:)
    /// ```
    ///
    /// ## Performance Requirements
    ///
    /// - ``subscript(offset:)`` must be O(1) for conforming types
    /// - ``starts(with:)`` must be O(prefix.count) without allocation
    public protocol Random<Element>: Input.`Protocol` {
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

// MARK: - Access Accessor

extension Input.Random {
    /// Accessor for random element access operations.
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
    public var access: Input.Access<Self> {
        withUnsafePointer(to: self) { ptr in
            Input.Access(ptr)
        }
    }
}

// MARK: - Prefix Comparison

extension Input.Random where Element: Equatable {
    /// Checks if remaining elements start with the given prefix.
    ///
    /// - Parameter prefix: Collection to compare against.
    /// - Returns: `true` if remaining elements start with prefix.
    /// - Complexity: O(prefix.count) without allocation.
    @inlinable
    public func starts<Prefix: Collection>(with prefix: Prefix) -> Bool
    where Prefix.Element == Element {
        guard prefix.count <= count else { return false }
        var offset = 0
        for element in prefix {
            if self[offset: offset] != element { return false }
            offset += 1
        }
        return true
    }

    /// Checks if the input starts with the given element.
    ///
    /// - Parameter element: Element to compare against.
    /// - Returns: `true` if remaining input starts with element.
    /// - Complexity: O(1)
    @inlinable
    public func starts(with element: Element) -> Bool {
        first == element
    }
}
