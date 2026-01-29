//
//  Input.Buffer+Input.Protocol.swift
//  swift-input-primitives
//
//  Input.Protocol conformance for Input.Buffer.
//

extension Input.Buffer: Input.`Protocol` {
    /// Checkpoint type is the typed index.
    ///
    /// Using `Index<Element>` maintains type safety throughout the
    /// checkpoint/restore mechanism.
    public typealias Checkpoint = Index<Element>

    /// The element type (forwarded from storage).
    public typealias Element = Storage.Element

    /// Total count of elements in storage.
    @inlinable
    var totalCount: Index<Element>.Count {
        try! Index<Element>.Count(storage.count)
    }

    @inlinable
    public var count: Index<Element>.Count {
        totalCount.subtract.saturating(Index<Element>.Count(position))
    }

    @inlinable
    public var isEmpty: Bool {
        position >= totalCount  // Typed comparison
    }

    /// Number of elements consumed since construction.
    @inlinable
    public var consumedCount: Index<Element>.Count {
        Index<Element>.Count(position)  // Position IS the consumed count
    }

    @inlinable
    public var first: Element? {
        _read {
            if !isEmpty {
                yield storage[rawIndex]  // Use rawIndex for subscripting
            } else {
                yield nil
            }
        }
    }

    @inlinable
    public var checkpoint: Checkpoint { position }

    @inlinable
    public var checkpointRange: ClosedRange<Checkpoint> {
        .zero...Index<Element>(totalCount)  // Typed range
    }

    // MARK: - Primitives

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = storage[rawIndex]
        position = position + .one  // Typed increment
        return element
    }

    @inlinable
    public mutating func advance(by count: Index<Element>.Count) {
        position = position + count  // Pure typed arithmetic!
    }

    @inlinable
    public mutating func setPosition(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
