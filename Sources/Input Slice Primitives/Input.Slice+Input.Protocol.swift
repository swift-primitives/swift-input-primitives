public import Collection_Primitives
public import Index_Primitives

extension Input.Slice: Input.Streaming
where
    Base: Collection.`Protocol`, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{}

extension Input.Slice: Input.`Protocol`
where
    Base: Collection.`Protocol`, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{

    public typealias Element = Base.Element

    public typealias Checkpoint = Index_Primitives.Index<Element>

    @usableFromInline
    var _total: Index_Primitives.Index<Element>.Count {

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
    public var count: Index_Primitives.Index<Element>.Count {
        _total.subtract.saturating(Index_Primitives.Index<Element>.Count(position))
    }

    @inlinable
    public var consumed: Index_Primitives.Index<Element>.Count {
        Index_Primitives.Index<Element>.Count(position)
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
    public mutating func advance(by count: Index_Primitives.Index<Element>.Count) {
        position += count
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
