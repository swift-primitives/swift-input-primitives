public import Property
public import Property_Inout

extension Input {

    public enum Restore {}
}

extension Input.Restorable where Self: ~Copyable {

    @inlinable
    public var restore: Property::Property<Input.Restore, Self>.Inout {
        mutating _read {
            yield Property::Property<Input.Restore, Self>.Inout(&self)
        }
    }
}

extension Property::Property.Inout
where Tag == Input.Restore, Base: Input.Restorable & ~Copyable {

    @inlinable
    public func to(__unchecked: Void, _ checkpoint: Base.Checkpoint) {
        base.value.seek(to: checkpoint)
    }
}
