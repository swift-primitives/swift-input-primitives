extension Input {

    public struct Buffer<Storage: RandomAccessCollection>: ~Copyable {

        @usableFromInline
        var storage: Storage

        @usableFromInline
        var position: Int

        @inlinable
        public init(_ storage: Storage) {
            self.storage = storage

            self.position = 0
        }
    }
}

extension Input.Buffer {

    @usableFromInline
    var _index: Storage.Index {
        storage.index(storage.startIndex, offsetBy: position)
    }
}

extension Input.Buffer {

    @inlinable
    public init<Element>(_ elements: [Element]) where Storage == ContiguousArray<Element> {
        self.storage = ContiguousArray(elements)

        self.position = 0
    }

    @inlinable
    public init<S: Swift.Sequence>(sequence: S) where Storage == ContiguousArray<S.Element> {
        self.storage = ContiguousArray(sequence)

        self.position = 0
    }

    @inlinable
    public init<Element>(
        repeating element: Element,
        count: Int
    ) where Storage == ContiguousArray<Element> {
        self.storage = ContiguousArray(repeating: element, count: count)
        self.position = 0
    }
}

extension Input.Buffer: Sendable where Storage: Sendable {}
