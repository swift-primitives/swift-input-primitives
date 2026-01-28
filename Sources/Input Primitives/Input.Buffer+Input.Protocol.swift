//
//  Input.Buffer+Input.Protocol.swift
//  swift-input-primitives
//
//  Input.Protocol conformance for Input.Buffer.
//

extension Input.Buffer: Input.`Protocol` {
    /// Checkpoint type is the storage's native index type.
    ///
    /// This provides efficient checkpoint/restore using the storage's
    /// own index representation.
    public typealias Checkpoint = Storage.Index

    /// The element type (forwarded from storage).
    public typealias Element = Storage.Element

    @inlinable
    public var count: Index<Element>.Count {
        try! Index<Element>.Count(storage.distance(from: position, to: storage.endIndex))
    }

    @inlinable
    public var isEmpty: Bool { position >= storage.endIndex }

    /// Number of elements consumed since construction.
    @inlinable
    public var consumedCount: Index<Element>.Count {
        try! Index<Element>.Count(storage.distance(from: storage.startIndex, to: position))
    }

    @inlinable
    public var first: Element? {
        _read {
            if position < storage.endIndex {
                yield storage[position]
            } else {
                yield nil
            }
        }
    }

    @inlinable
    public var checkpoint: Checkpoint { position }

    @inlinable
    public var checkpointRange: ClosedRange<Checkpoint> {
        storage.startIndex...storage.endIndex
    }

    // MARK: - Primitives

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard position < storage.endIndex else {
            throw .empty
        }
        let element = storage[position]
        position = storage.index(after: position)
        return element
    }

    @inlinable
    public mutating func advance(by offset: Index<Element>.Offset) {
        position = storage.index(position, offsetBy: offset)
    }

    @inlinable
    public mutating func setPosition(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
