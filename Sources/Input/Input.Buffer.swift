public import Index

extension Input {

    public struct Buffer<Storage: RandomAccessCollection>: ~Copyable
    where Storage.Index: Hashable {

        @usableFromInline
        var storage: Storage

        @usableFromInline
        var position: Index<Storage.Element>

        @inlinable
        public init(_ storage: Storage) {
            self.storage = storage

            self.position = .zero
        }
    }
}

extension Input.Buffer {

    @usableFromInline
    var _index: Storage.Index {
        storage.index(storage.startIndex, offsetBy: Int(bitPattern: position))
    }
}

extension Input.Buffer {

    @inlinable
    public init<Element>(_ elements: [Element]) where Storage == ContiguousArray<Element> {
        self.storage = ContiguousArray(elements)

        self.position = .zero
    }

    @inlinable
    public init<S: Swift.Sequence>(sequence: S) where Storage == ContiguousArray<S.Element> {
        self.storage = ContiguousArray(sequence)

        self.position = .zero
    }

    @inlinable
    public init<Element>(
        repeating element: Element,
        count: Index<Element>.Count
    ) where Storage == ContiguousArray<Element> {
        self.storage = ContiguousArray(repeating: element, count: count)
        self.position = .zero
    }
}

extension Input.Buffer: Sendable where Storage: Sendable {}
