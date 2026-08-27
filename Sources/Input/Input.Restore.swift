extension Input {

    public enum Restore {}
}

extension Input.`Protocol` where Self: ~Copyable {

    @inlinable
    public mutating func restore(to checkpoint: Checkpoint) throws(Input.Restore.Error) {
        guard isValid(checkpoint) else {
            throw .invalidCheckpoint
        }
        seek(to: checkpoint)
    }
}
