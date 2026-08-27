public import Property

extension Input {

    public enum Restore {}
}

extension Input.Restorable where Self: ~Copyable {

    @inlinable
    public var restore: Property<Input.Restore, Self>.Inout {
        mutating _read {
            yield Property.Inout(&self)
        }
    }
}

extension Property.Inout where Tag == Input.Restore, Base: Input.Restorable & ~Copyable {

    @inlinable
    public func to(__unchecked: Void, _ checkpoint: Base.Checkpoint) {
        base.value.seek(to: checkpoint)
    }
}
