//
//  Input.Buffer+Input.Protocol.swift
//  swift-input-primitives
//
//  Input.Protocol conformance for Input.Buffer.
//

extension Input.Buffer: Input.`Protocol` {
    public typealias Checkpoint = Int

    /// The total number of elements in the storage.
    @usableFromInline
    var totalCount: Int { storage.count }

    @inlinable
    public var count: Int { totalCount - position }

    @inlinable
    public var isEmpty: Bool { position >= totalCount }

    /// Number of elements consumed since construction.
    @inlinable
    public var consumedCount: Int { position }

    @inlinable
    public var first: Element? {
        guard position < totalCount else { return nil }
        return storage[position]
    }

    @inlinable
    public var checkpoint: Checkpoint { position }

    @inlinable
    public mutating func restore(to checkpoint: Checkpoint) throws(Input.Error) {
        guard checkpoint >= 0 && checkpoint <= totalCount else {
            throw .invalidCheckpoint
        }
        position = checkpoint
    }

    @inlinable
    @discardableResult
    public mutating func removeFirst() throws(Input.Error) -> Element {
        guard position < totalCount else {
            throw .empty
        }
        let element = storage[position]
        position += 1
        return element
    }

    @inlinable
    public mutating func removeFirst(_ n: Int) throws(Input.Error) {
        guard n >= 0 && n <= count else {
            throw .insufficientElements(requested: n, available: count)
        }
        position += n
    }
}
