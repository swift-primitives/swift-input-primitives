extension Input {

    public enum Restore {}
}

extension Input.`Protocol` where Self: ~Copyable {

    @inlinable
    public var restore: Property<Input.Restore, Self>.Inout {
        mutating _read {
            yield Property.Inout(&self)
        }
    }
}

extension Property.Inout where Tag == Input.Restore, Base: Input.`Protocol` & ~Copyable {

    @inlinable
    public func to(_ checkpoint: Base.Checkpoint) throws(Input.Restore.Error) {
        guard base.value.isValid(checkpoint) else {
            throw .invalidCheckpoint
        }
        base.value.seek(to: checkpoint)
    }

    @inlinable
    public func to(__unchecked: Void, _ checkpoint: Base.Checkpoint) {
        base.value.seek(to: checkpoint)
    }
}
