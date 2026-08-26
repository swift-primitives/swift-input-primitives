extension Property.Inout where Tag == Input.Restore, Base: Input.`Protocol` & ~Copyable {

    @inlinable
    public func to(_ checkpoint: Base.Checkpoint) throws(Input.Restore.Error) {
        guard base.value.isValid(checkpoint) else {
            throw .invalidCheckpoint
        }
        base.value.seek(to: checkpoint)
    }
}
