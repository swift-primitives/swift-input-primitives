public import Affine_Arithmetic
public import Affine_Tagged
public import Cardinal
public import Collection_Slice
public import Index
public import Iterator
public import Iterator_Chunk
public import Iterator_Protocol
public import Ordinal
public import Ordinal_Protocol
public import Ordinal_Tagged
public import Sequence_Borrowing
public import Tagged

internal import Ordinal_Error

extension Input.Slice
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{

    public struct Iterator: Iterator::Iterator.`Protocol` {
        @usableFromInline let base: Base
        @usableFromInline let _upper: Base.Index
        @usableFromInline var current: Base.Index

        @usableFromInline
        init(base: Base, start: Base.Index, end: Base.Index) {
            self.base = base
            self._upper = end
            self.current = start
        }
    }
}

extension Input.Slice.Iterator
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{

    public typealias Element = Base.Element

    @inlinable
    public mutating func next() -> Base.Element? {
        guard current < _upper else { return nil }
        let element = base[current]
        current = base.index(after: current)
        return element
    }
}

extension Input.Slice: Sequence.Borrowing.`Protocol`
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{

    @_implements(Sequence.Borrowing.`Protocol`, Iterator)
    public typealias BorrowingIterator = Iterator::Iterator.Materializing<Iterator>

    @inlinable
    @_lifetime(borrow self)
    @_implements(Sequence.Borrowing.`Protocol`, makeIterator())
    public borrowing func borrowingMakeIterator()
        -> Iterator::Iterator.Materializing<Iterator>
    {
        Iterator::Iterator.Materializing(Iterator(base: base, start: _index, end: _upper))
    }

    @inlinable
    public borrowing func makeIterator() -> Iterator {
        Iterator(base: base, start: _index, end: _upper)
    }
}

extension Input.Slice: Collection.`Protocol`
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{

    @inlinable
    public var startIndex: Index::Index<Element> { position }

    @inlinable
    public var endIndex: Index::Index<Element> {
        Index::Index<Element>(_unchecked: Ordinal(_total.underlying.rawValue))
    }

    @inlinable
    public subscript(position: Index::Index<Element>) -> Element {
        base[_lower + Index::Index<Element>.Count(position)]
    }

    @inlinable
    public func index(after i: Index::Index<Element>) -> Index::Index<Element> {

        do throws(Ordinal.Error) {
            return try i + Index::Index<Element>.Offset(1)
        } catch {
            return i
        }
    }
}

extension Input.Slice.Iterator: IteratorProtocol
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{}

extension Input.Slice: Swift.Sequence
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{

    public var underestimatedCount: Int { Int(bitPattern: count.underlying.rawValue) }
}

extension Input.Slice: Swift.Collection
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{

    public typealias SubSequence = Self

    @inlinable
    public func formIndex(after i: inout Index::Index<Element>) {
        i = index(after: i)
    }
}

extension Input.Slice: Collection.Slice.`Protocol`
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{

    @inlinable
    public subscript(bounds: Range<Index::Index<Element>>) -> Self {
        let absStart = _lower + Index::Index<Element>.Count(bounds.lowerBound)
        let absEnd = _lower + Index::Index<Element>.Count(bounds.upperBound)
        return Input.Slice(_unchecked: (), base: base, startIndex: absStart, endIndex: absEnd)
    }
}
