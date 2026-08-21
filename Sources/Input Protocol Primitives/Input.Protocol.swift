extension Input {

    public protocol `Protocol`<Element>: Streaming, ~Copyable {

        associatedtype Checkpoint: Comparable

        var count: Index<Element>.Count { get }

        var checkpoint: Checkpoint { get }

        var bounds: ClosedRange<Checkpoint> { get }

        mutating func seek(to checkpoint: Checkpoint)

        mutating func advance(by count: Index<Element>.Count)
    }
}

extension Input.`Protocol` where Self: ~Copyable {

    @inlinable
    public func isValid(_ checkpoint: Checkpoint) -> Bool {
        bounds.contains(checkpoint)
    }
}

extension Input.`Protocol` where Self: Copyable {

    @inlinable
    public var remaining: Self {
        self
    }
}
