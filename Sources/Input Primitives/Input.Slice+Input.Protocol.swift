//
//  Input.Slice+Input.Protocol.swift
//  swift-input-primitives
//
//  Input.Protocol conformance for Input.Slice.
//

public import Collection_Primitives

extension Input.Slice: Input.`Protocol` {
    public typealias Element = Base.Element

    /// Checkpoint type is the collection's native index type.
    public typealias Checkpoint = Base.Index

    @inlinable
    public var isEmpty: Bool {
        startIndex >= endIndex
    }

    @inlinable
    public var count: Index<Element>.Count {
        try! Index<Element>.Count(base.distance(from: startIndex, to: endIndex))
    }

    @inlinable
    public var first: Element? {
        _read {
            if startIndex < endIndex {
                yield base[startIndex]
            } else {
                yield nil
            }
        }
    }

    @inlinable
    public var checkpoint: Checkpoint {
        startIndex
    }

    @inlinable
    public var checkpointRange: ClosedRange<Checkpoint> {
        // Valid range: from base start to our endIndex
        // (can restore to any position we've seen, up to end)
        base.startIndex...endIndex
    }

    // MARK: - Primitives

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard startIndex < endIndex else {
            throw .empty
        }
        let element = base[startIndex]
        startIndex = base.index(after: startIndex)
        return element
    }

    @inlinable
    public mutating func advance(by offset: Index<Element>.Offset) {
        startIndex = base.index(startIndex, offsetBy: offset)
    }

    @inlinable
    public mutating func setPosition(to checkpoint: Checkpoint) {
        startIndex = checkpoint
    }
}
