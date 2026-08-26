extension Input.Buffer: Input.`Protocol` {

    public typealias Checkpoint = Index<Element>

    public typealias Element = Storage.Element

    @usableFromInline
    var _total: Index<Element>.Count {

        do throws(Cardinal.Error) {
            return try Index<Element>.Count(storage.count)
        } catch {
            return .zero
        }
    }

    @inlinable
    public var count: Index<Element>.Count {
        _total.subtract.saturating(Index<Element>.Count(position))
    }

    @inlinable
    public var isEmpty: Bool {
        position >= _total
    }

    @inlinable
    public var consumed: Index<Element>.Count {
        Index<Element>.Count(position)
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
        .zero..._total.map(Ordinal.init)
    }

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = storage[_index]
        position += .one
        return element
    }

    @inlinable
    public mutating func advance(by count: Index<Element>.Count) {
        position += count
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
