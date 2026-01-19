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
    public mutating func restore(to checkpoint: Checkpoint) {
        startIndex = checkpoint
    }

    @inlinable
    @discardableResult
    public mutating func removeFirst() -> Element {
        let element = base[startIndex]
        startIndex = base.index(after: startIndex)
        return element
    }

    @inlinable
    public mutating func removeFirst(_ n: Int) {
        startIndex = base.index(startIndex, offsetBy: n)
    }
}
