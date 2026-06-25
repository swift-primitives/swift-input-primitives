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
    /// - `consumed == distance(from: startIndex, to: position)`
    ///
    /// ## Sendable
    ///
    /// `Sendable` when `Storage` and `Storage.Index` are `Sendable` (conditional
    /// conformance declared via extension below). The `Sendable` bounds are
    /// *not* struct-level constraints per [MEM-SEND-013] — region-based
    /// isolation is the consumer's responsibility at the call site.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input = Input.Buffer([0x48, 0x65, 0x6C, 0x6C, 0x6F])
    ///
    /// let checkpoint = input.checkpoint
    /// let byte = try input.advance()  // 0x48
    ///
    /// input.seek(to: checkpoint)
    /// assert(input.first == 0x48)  // Back to start
    /// ```
    public struct Buffer<Storage: RandomAccessCollection>: ~Copyable
    where Storage.Index: Hashable {
        /// The underlying storage.
        @usableFromInline
        var storage: Storage

        /// The current position as a typed index.
        ///
        /// Primary representation for typed arithmetic (`position + count`).
        /// Raw `Storage.Index` is derived via `_index` when subscripting.
        @usableFromInline
        var position: Index<Storage.Element>

        /// Creates a buffer cursor over the given storage.
        ///
        /// - Parameter storage: The random-access collection to wrap.
        @inlinable
        public init(_ storage: Storage) {
            self.storage = storage
            // swift-linter:disable:next raw value access
            // REASON: extension-initializer same-package boundary — `self.position` is the
            // brand-newtype's own stored property, not an `Index.position` accessor.
            self.position = .zero
        }
    }
}

// MARK: - Internal Helpers

extension Input.Buffer {
    /// The raw storage index for subscripting.
    ///
    /// O(1) for `RandomAccessCollection`. Conversion encapsulated here.
    @usableFromInline
    var _index: Storage.Index {
        storage.index(storage.startIndex, offsetBy: Int(bitPattern: position))
    }
}

// MARK: - Convenience Initializers for ContiguousArray

extension Input.Buffer {
    /// Creates a buffer cursor by copying elements into a ContiguousArray.
    ///
    /// - Parameter elements: The array to copy into the buffer.
    @inlinable
    public init<Element>(_ elements: [Element]) where Storage == ContiguousArray<Element> {
        self.storage = ContiguousArray(elements)
        // swift-linter:disable:next raw value access
        // REASON: extension-initializer same-package boundary — `self.position` is the
        // brand-newtype's own stored property, not an `Index.position` accessor.
        self.position = .zero
    }

    /// Creates a buffer cursor by copying elements from a sequence into a ContiguousArray.
    ///
    /// - Parameter sequence: The sequence to copy into the buffer.
    @inlinable
    public init<S: Swift.Sequence>(sequence: S) where Storage == ContiguousArray<S.Element> {
        self.storage = ContiguousArray(sequence)
        // swift-linter:disable:next raw value access
        // REASON: extension-initializer same-package boundary — `self.position` is the
        // brand-newtype's own stored property, not an `Index.position` accessor.
        self.position = .zero
    }

    /// Creates a buffer cursor with repeating element in a ContiguousArray.
    ///
    /// - Parameters:
    ///   - element: The element to repeat.
    ///   - count: The number of times to repeat the element.
    @inlinable
    public init<Element>(
        repeating element: Element,
        count: Index<Element>.Count
    ) where Storage == ContiguousArray<Element> {
        self.storage = ContiguousArray(repeating: element, count: count)
        self.position = .zero
    }
}

// MARK: - Sendable

extension Input.Buffer: Sendable where Storage: Sendable {}
