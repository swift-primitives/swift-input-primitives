public import Cardinal
public import Cardinal_Carrier
public import Cardinal_Tagged
public import Index
public import Input_Protocol
public import Input_Stream
public import Ordinal
public import Ordinal_Cardinal
public import Ordinal_Protocol
public import Ordinal_Tagged
public import Tagged

internal import Cardinal_Error

extension Input.Buffer: Input.`Protocol` {

    public typealias Checkpoint = Index::Index<Element>

    public typealias Element = Storage.Element

    @usableFromInline
    var _total: Index::Index<Element>.Count {

        do throws(Cardinal.Error) {
            return try Index::Index<Element>.Count(storage.count)
        } catch {
            return .zero
        }
    }

    @inlinable
    public var count: Index::Index<Element>.Count {
        _total.subtract.saturating(Index::Index<Element>.Count(position))
    }

    @inlinable
    public var isEmpty: Bool {
        position >= _total
    }

    @inlinable
    public var consumed: Index::Index<Element>.Count {
        Index::Index<Element>.Count(position)
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
        .zero...Index::Index<Element>(
            _unchecked: Ordinal(_total.underlying.rawValue)
        )
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
    public mutating func advance(by count: Index::Index<Element>.Count) {
        position += count
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
