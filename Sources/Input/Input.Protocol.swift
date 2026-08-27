extension Input {

    public protocol `Protocol`<Element>: Restorable, Streaming, ~Copyable
    where Checkpoint: Comparable {

        var count: Int { get }

        var bounds: ClosedRange<Checkpoint> { get }

        mutating func advance(by count: Int)
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
