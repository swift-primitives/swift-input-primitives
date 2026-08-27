extension Input.Buffer: Input.`Protocol` {

    public typealias Checkpoint = Int

    public typealias Element = Storage.Element

    @usableFromInline
    var _total: Int {
        storage.count
    }

    @inlinable
    public var count: Int {
        _total - position
    }

    @inlinable
    public var isEmpty: Bool {
        position >= _total
    }

    @inlinable
    public var consumed: Int {
        position
    }

    @inlinable
    public var first: Element? {
        _read {
            if !isEmpty {
                yield storage[_index]
            } else {
                yield nil
            }
        }
    }

    @inlinable
    public var checkpoint: Checkpoint { position }

    @inlinable
    public var bounds: ClosedRange<Checkpoint> {
        0..._total
    }

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = storage[_index]
        position += 1
        return element
    }

    @inlinable
    public mutating func advance(by count: Int) {
        precondition(count >= 0 && count <= self.count)
        position += count
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
