//
//  Input.Buffer.swift
//  swift-input-primitives
//
//  Owned buffer cursor for parsing, generic over storage type.
//

extension Input {
    /// Owned buffer cursor for parsing.
    ///
    /// Stores an owned random-access collection with a position cursor.
    /// The cursor advances through the storage without modifying it,
    /// enabling efficient checkpoint/restore for backtracking parsers.
    ///
    /// ## Generic Storage
    ///
    /// `Input.Buffer` is generic over any `RandomAccessCollection`:
    ///
    /// ```swift
    /// // With Array.Bounded from array-primitives:
    /// var input = Input.Buffer(storage: myBoundedArray)
    ///
    /// // With ContiguousArray:
    /// var input = Input.Buffer(ContiguousArray([1, 2, 3, 4, 5]))
    ///
    /// // With Swift.Array:
    /// var input = Input.Buffer([1, 2, 3, 4, 5])
    /// ```
    ///
    /// ## Invariants
    ///
    /// - `startIndex <= position <= endIndex`
    /// - `count == distance(from: position, to: endIndex)`
    /// - `consumedCount == distance(from: startIndex, to: position)`
    ///
    /// ## Sendable
    ///
    /// `Sendable` when `Storage` and `Storage.Index` are `Sendable`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input = Input.Buffer([0x48, 0x65, 0x6C, 0x6C, 0x6F])
    ///
    /// let checkpoint = input.checkpoint
    /// let byte = try input.advance()  // 0x48
    ///
    /// input.setPosition(to: checkpoint)
    /// assert(input.first == 0x48)  // Back to start
    /// ```
    public struct Buffer<Storage: RandomAccessCollection & Sendable>: ~Copyable
    where Storage.Element: Sendable, Storage.Index: Sendable & Hashable {
        /// The underlying storage.
        @usableFromInline
        var storage: Storage

        /// The current position in the storage.
        @usableFromInline
        var position: Storage.Index

        /// Creates a buffer cursor over the given storage.
        ///
        /// - Parameter storage: The random-access collection to wrap.
        @inlinable
        public init(_ storage: Storage) {
            self.storage = storage
            self.position = storage.startIndex
        }
    }
}

// MARK: - Convenience Initializers for ContiguousArray

extension Input.Buffer {
    /// Creates a buffer cursor by copying elements into a ContiguousArray.
    ///
    /// - Parameter elements: The array to copy into the buffer.
    @inlinable
    public init<Element: Sendable>(_ elements: [Element]) where Storage == ContiguousArray<Element> {
        self.storage = ContiguousArray(elements)
        self.position = storage.startIndex
    }

    /// Creates a buffer cursor by copying elements from a sequence into a ContiguousArray.
    ///
    /// - Parameter sequence: The sequence to copy into the buffer.
    @inlinable
    public init<S: Swift.Sequence>(sequence: S) where Storage == ContiguousArray<S.Element>, S.Element: Sendable {
        self.storage = ContiguousArray(sequence)
        self.position = storage.startIndex
    }

    /// Creates a buffer cursor with repeating element in a ContiguousArray.
    ///
    /// - Parameters:
    ///   - repeating: The element to repeat.
    ///   - count: The number of times to repeat the element.
    @inlinable
    public init<Element: Sendable>(repeating element: Element, count: Int) where Storage == ContiguousArray<Element> {
        self.storage = ContiguousArray(repeating: element, count: Swift.max(0, count))
        self.position = storage.startIndex
    }
}

// MARK: - Sendable

extension Input.Buffer: @unchecked Sendable where Storage: Sendable, Storage.Index: Sendable {}
