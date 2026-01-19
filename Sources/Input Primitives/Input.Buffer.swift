//
//  Input.Buffer.swift
//  swift-input-primitives
//
//  Owned buffer cursor for parsing.
//

extension Input {
    /// Owned buffer cursor for parsing.
    ///
    /// Stores an owned `[Element]` array with a position cursor.
    /// Fully `Sendable` because storage is a value type.
    ///
    /// ## Invariants
    ///
    /// - `0 <= position <= storage.count`
    /// - `count == storage.count - position`
    /// - `consumedCount == position`
    ///
    /// ## Sendable
    ///
    /// Fully `Sendable` because storage is an owned `[Element]` value type.
    /// Safe to transfer across concurrency domains.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input = Input.Buffer([0x48, 0x65, 0x6C, 0x6C, 0x6F])
    ///
    /// let checkpoint = input.checkpoint
    /// let byte = input.removeFirst()  // 0x48
    ///
    /// input.restore(to: checkpoint)
    /// assert(input.first == 0x48)
    /// ```
    public struct Buffer<Element: Sendable>: Sendable {
        /// The underlying storage.
        @usableFromInline
        var storage: [Element]

        /// The current position in the storage.
        @usableFromInline
        var position: Int

        /// Creates a buffer cursor over the given array.
        ///
        /// - Parameter elements: The array to wrap.
        @inlinable
        public init(_ elements: [Element]) {
            self.storage = elements
            self.position = 0
        }

        /// Creates a buffer cursor from a sequence.
        ///
        /// - Parameter sequence: The sequence to copy into the buffer.
        @inlinable
        public init<S: Sequence>(_ sequence: S) where S.Element == Element {
            self.storage = Array(sequence)
            self.position = 0
        }

        /// Creates a buffer cursor with repeating element.
        ///
        /// - Parameters:
        ///   - repeating: The element to repeat.
        ///   - count: The number of times to repeat the element.
        @inlinable
        public init(repeating element: Element, count: Int) {
            self.storage = Array(repeating: element, count: count)
            self.position = 0
        }
    }
}
