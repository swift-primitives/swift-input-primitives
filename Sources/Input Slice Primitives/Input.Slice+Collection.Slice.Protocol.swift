public import Collection_Primitives
public import Index_Primitives
public import Iterable
public import Iterator_Chunk_Primitives
public import Iterator_Primitive

extension Input.Slice
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{

    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
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
    Base.Index == Index_Primitives.Index<Base.Element>
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

extension Input.Slice: Iterable
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{

    @_implements(Iterable,Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Materializing<Iterator>

    @inlinable
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Iterator(base: base, start: _index, end: _upper))
    }

    @inlinable
    public borrowing func makeIterator() -> Iterator {
        Iterator(base: base, start: _index, end: _upper)
    }
}

extension Input.Slice: Collection.`Protocol`
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{

    @inlinable
    public var startIndex: Index_Primitives.Index<Element> { position }

    @inlinable
    public var endIndex: Index_Primitives.Index<Element> { _total.map(Ordinal.init) }

    @inlinable
    public subscript(position: Index_Primitives.Index<Element>) -> Element {
        base[_lower + Index_Primitives.Index<Element>.Count(position)]
    }

    @inlinable
    public func index(after i: Index_Primitives.Index<Element>) -> Index_Primitives.Index<Element> {

        do throws(Ordinal.Error) {
            return try i + Index_Primitives.Index<Element>.Offset(1)
        } catch {
            return i
        }
    }
}

extension Input.Slice.Iterator: IteratorProtocol
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{}

extension Input.Slice: Swift.Sequence
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{

    public var underestimatedCount: Int { Int(bitPattern: count) }
}

extension Input.Slice: Swift.Collection
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{

    public typealias SubSequence = Self

    @inlinable
    public func formIndex(after i: inout Index_Primitives.Index<Element>) {
        i = index(after: i)
    }
}

extension Input.Slice: Collection.Slice.`Protocol`
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{

    @inlinable
    public subscript(bounds: Range<Index_Primitives.Index<Element>>) -> Self {
        let absStart = _lower + Index_Primitives.Index<Element>.Count(bounds.lowerBound)
        let absEnd = _lower + Index_Primitives.Index<Element>.Count(bounds.upperBound)
        return Input.Slice(_unchecked: (), base: base, startIndex: absStart, endIndex: absEnd)
    }
}
