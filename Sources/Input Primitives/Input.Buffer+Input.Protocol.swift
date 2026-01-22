//
//  Input.Buffer+Input.Protocol.swift
//  swift-input-primitives
//
//  Input.Protocol conformance for Input.Buffer.
//

extension Input.Buffer: Input.`Protocol` {
    /// Checkpoint type using phantom-typed `Index<Element>` from index-primitives.
    ///
    /// This provides:
    /// - Type safety: `Index<Int>` ≠ `Index<String>`
    /// - Non-negative guarantee: from `Affine.Discrete.Position`
    /// - Sendable + Comparable conformance
    public typealias Checkpoint = Index<Element>

    /// The total number of elements in the storage.
    @usableFromInline
    var totalCount: Index<Element>.Count { storage.count }

    @inlinable
    public var count: Int { totalCount.rawValue - position.position.rawValue }

    @inlinable
    public var isEmpty: Bool { position >= totalCount }

    /// Number of elements consumed since construction.
    @inlinable
    public var consumedCount: Int { position.position.rawValue }

    @inlinable
    public var first: Element? {
        guard position < totalCount else { return nil }
        return storage[position]
    }

    @inlinable
    public var checkpoint: Checkpoint { position }

    @inlinable
    public var checkpointRange: ClosedRange<Checkpoint> {
        .zero...Checkpoint(totalCount)
    }

    // MARK: - Primitives

    @inlinable
    @discardableResult
    public mutating func advance() -> Element {
        let element = storage[position]
        position = (position + 1)!
        return element
    }

    @inlinable
    public mutating func advance(by count: Int) {
        position = (position + Index<Element>.Offset(count))!
    }

    @inlinable
    public mutating func setPosition(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
