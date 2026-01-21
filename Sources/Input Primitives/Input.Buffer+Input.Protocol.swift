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

    // MARK: - Unchecked Primitives

    @inlinable
    @discardableResult
    public mutating func __removeFirstUnchecked() -> Element {
        let element = storage[position]
        position += 1
        return element
    }

    @inlinable
    public mutating func __removeFirstUnchecked(_ count: Int) {
        position += count
    }

    @inlinable
    public func __isValidCheckpoint(_ checkpoint: Checkpoint) -> Bool {
        checkpoint >= 0 && checkpoint <= totalCount
    }

    @inlinable
    public mutating func __restoreUnchecked(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
