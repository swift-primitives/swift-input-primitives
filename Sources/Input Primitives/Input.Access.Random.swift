//
//  Input.Access.Random.swift
//  swift-input-primitives
//
//  Protocol refinement for random access within remaining input.
//

extension Input.Access {
    /// A type that provides random access within the remaining input.
    ///
    /// Extends ``Input/Protocol`` with offset-based subscript and prefix
    /// comparison, enabling efficient lookahead without consumption.
    ///
    /// ## Totality
    ///
    /// - `subscript(offset:)` is unchecked per stdlib Collection subscript convention
    /// - `element(at:)` provides total access with typed throws
    ///
    /// ## Protocol Hierarchy
    ///
    /// ```
    /// Input.Streaming      ← minimal, forward-only
    ///       ↑
    /// Input.Protocol       ← checkpoint/restore
    ///       ↑
    /// Input.Access.Random  ← subscript(offset:), starts(with:)
    /// ```
    ///
    /// ## Use Cases
    ///
    /// - Machine leaf instructions like `bytes(expected)` that need lookahead
    /// - Efficient prefix matching without consuming input
    /// - Random access for complex grammar recognition
    ///
    /// ## Performance Requirements
    ///
    /// - ``subscript(offset:)`` must be O(1) for conforming types
    /// - ``starts(with:)`` must be O(prefix.count) without allocation
    ///
    /// ## Example
    ///
    /// ```swift
    /// let input = Input.Buffer([0x48, 0x65, 0x6C, 0x6C, 0x6F])
    ///
    /// // Offset access without consumption
    /// assert(input[offset: 0] == 0x48)
    /// assert(input[offset: 4] == 0x6F)
    ///
    /// // Prefix check without consumption
    /// assert(input.starts(with: [0x48, 0x65]))  // "He"
    /// assert(!input.starts(with: [0x48, 0x69])) // Not "Hi"
    /// ```
    public protocol Random<Element>: Input.`Protocol` {
        /// Accesses the element at the given offset from current position.
        ///
        /// This is unchecked per stdlib Collection subscript convention.
        /// For total access, use ``element(at:)``.
        ///
        /// - Parameter offset: Offset from current position (0-indexed).
        /// - Precondition: `offset >= 0` and `offset < count`.
        /// - Complexity: O(1)
        subscript(offset offset: Int) -> Element { get }

        /// Accesses the element at the given offset with bounds checking.
        ///
        /// - Parameter offset: Offset from current position (0-indexed).
        /// - Returns: The element at the offset.
        /// - Throws: ``Input/Error/insufficientElements(requested:available:)``
        ///   if `offset < 0` or `offset >= count`.
        /// - Complexity: O(1)
        func element(at offset: Int) throws(Input.Error) -> Element
    }
}

// MARK: - Default Implementation

extension Input.Access.Random {
    /// Default implementation of total element access.
    @inlinable
    public func element(at offset: Int) throws(Input.Error) -> Element {
        guard offset >= 0 && offset < count else {
            throw .insufficientElements(requested: offset + 1, available: count)
        }
        return self[offset: offset]
    }
}

// MARK: - Prefix Comparison

extension Input.Access.Random where Element: Equatable {
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
