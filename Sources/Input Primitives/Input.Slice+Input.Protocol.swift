//
//  Input.Slice+Input.Protocol.swift
//  swift-input-primitives
//
//  Input.Protocol conformance for Input.Slice.
//

extension Input.Slice: Input.`Protocol` {
    public typealias Element = Base.Element

    /// Checkpoint type is the collection's native index type.
    public typealias Checkpoint = Base.Index

    @inlinable
    public var isEmpty: Bool {
        startIndex >= endIndex
    }

    @inlinable
    public var count: Int {
        base.distance(from: startIndex, to: endIndex)
    }

    @inlinable
    public var first: Element? {
        isEmpty ? nil : base[startIndex]
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
    public mutating func advance() -> Element {
        let element = base[startIndex]
        startIndex = base.index(after: startIndex)
        return element
    }

    @inlinable
    public mutating func advance(by count: Int) {
        startIndex = base.index(startIndex, offsetBy: count)
    }

    @inlinable
    public mutating func setPosition(to checkpoint: Checkpoint) {
        startIndex = checkpoint
    }
}
