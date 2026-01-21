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

    @inlinable
    public mutating func restore(to checkpoint: Checkpoint) throws(Input.Error) {
        // Validate checkpoint is within the original slice bounds.
        // A valid checkpoint must be >= base.startIndex and <= endIndex
        // (can restore to end position, which means empty).
        guard checkpoint >= base.startIndex && checkpoint <= endIndex else {
            throw .invalidCheckpoint
        }
        startIndex = checkpoint
    }

    @inlinable
    @discardableResult
    public mutating func removeFirst() throws(Input.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = base[startIndex]
        startIndex = base.index(after: startIndex)
        return element
    }

    @inlinable
    public mutating func removeFirst(_ n: Int) throws(Input.Error) {
        guard n >= 0 && n <= count else {
            throw .insufficientElements(requested: n, available: count)
        }
        startIndex = base.index(startIndex, offsetBy: n)
    }
}
