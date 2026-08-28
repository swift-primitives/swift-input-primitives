public import Collection_Protocol
public import Cardinal_Carrier
public import Cardinal_Tagged
public import Index
public import Ordinal
public import Ordinal_Cardinal
public import Ordinal_Protocol
public import Ordinal_Tagged
public import Tagged

internal import Ordinal_Error
internal import Ordinal_Distance

extension Input.Slice: Input.Streaming
where
    Base: Collection.`Protocol`, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{}

extension Input.Slice: Input.Restorable
where
    Base: Collection.`Protocol`, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{}

extension Input.Slice: Input.`Protocol`
where
    Base: Collection.`Protocol`, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{

    public typealias Element = Base.Element

    public typealias Checkpoint = Index::Index<Element>

    @usableFromInline
    var _total: Index::Index<Element>.Count {

        do throws(Ordinal.Error) {
            return try _lower.distance.forward(to: _upper)
        } catch {
            return .zero
        }
    }

    @inlinable
    public var isEmpty: Bool {
        position >= _total
    }

    @inlinable
    public var count: Index::Index<Element>.Count {
        _total.subtract.saturating(Index::Index<Element>.Count(position))
    }

    @inlinable
    public var consumed: Index::Index<Element>.Count {
        Index::Index<Element>.Count(position)
    }

    @inlinable
    public var first: Element? {
        _read {
            if !isEmpty {
                yield base[_index]
            } else {
                yield nil
            }
        }
    }

    @inlinable
    public var checkpoint: Checkpoint {
        position
    }

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
        let element = base[_index]
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
