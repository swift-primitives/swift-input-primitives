extension Input {

    public protocol Restorable: ~Copyable, ~Escapable {

        associatedtype Checkpoint

        var checkpoint: Checkpoint { get }

        mutating func seek(to checkpoint: Checkpoint)
    }
}

extension Input.Restorable where Self: Copyable, Checkpoint == Self {

    @inlinable
    public var checkpoint: Self {
        self
    }

    @inlinable
    public mutating func seek(to checkpoint: Self) {
        self = checkpoint
    }
}
