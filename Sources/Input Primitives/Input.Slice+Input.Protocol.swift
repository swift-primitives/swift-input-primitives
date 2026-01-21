//
//  Input.Slice+Input.Protocol.swift
//  swift-input-primitives
//
//  Input.Protocol conformance for Input.Slice.
//

extension Input.Slice: Input.`Protocol` {
    public typealias Element = Base.Element
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

    // MARK: - Unchecked Primitives

    @inlinable
    @discardableResult
    public mutating func __removeFirstUnchecked() -> Element {
        let element = base[startIndex]
        startIndex = base.index(after: startIndex)
        return element
    }

    @inlinable
    public mutating func __removeFirstUnchecked(_ count: Int) {
        startIndex = base.index(startIndex, offsetBy: count)
    }

    @inlinable
    public func __isValidCheckpoint(_ checkpoint: Checkpoint) -> Bool {
        // A valid checkpoint must be >= base.startIndex and <= endIndex
        // (can restore to end position, which means empty).
        checkpoint >= base.startIndex && checkpoint <= endIndex
    }

    @inlinable
    public mutating func __restoreUnchecked(to checkpoint: Checkpoint) {
        startIndex = checkpoint
    }
}
