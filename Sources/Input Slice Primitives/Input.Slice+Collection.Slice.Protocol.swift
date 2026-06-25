//
//  Input.Slice+Collection.Slice.Protocol.swift
//  swift-input-primitives
//
//  Collection.Slice.Protocol conformance for Input.Slice.
//
//  Provides index-based collection access and self-slicing,
//  enabling parsers to operate via Collection.Slice.Protocol
//  instead of stdlib Collection.
//

public import Collection_Primitives
public import Index_Primitives
public import Iterable
public import Iterator_Chunk_Primitives
public import Iterator_Primitive

// MARK: - Iterator

extension Input.Slice where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    /// Iterator over the elements of an `Input.Slice`.
    ///
    /// Walks the underlying base collection from `_lower` to `_upper` via scalar
    /// `next()`. `Input.Slice`'s `Iterable` conformance wraps this scalar iterator in
    /// `Iterator.Materializing` for bulk span access over index-based collections.
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

// MARK: - Iterator: scalar next() (Iterator.Protocol witness)

extension Input.Slice.Iterator where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    /// The element type yielded by the iterator.
    public typealias Element = Base.Element

    /// Returns the next element, advancing the iterator.
    @inlinable
    public mutating func next() -> Base.Element? {
        guard current < _upper else { return nil }
        let element = base[current]
        current = base.index(after: current)
        return element
    }
}

// MARK: - Sequence.Protocol

extension Input.Slice: Iterable
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    // reason: comma spacing inside @_implements conflicts with SwiftLint comma rule
    // swift-format-ignore
    /// The scalar slice iterator wrapped in the materializing adapter for bulk span access.
    @_implements(Iterable, Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Materializing<Iterator>

    // reason: comma spacing inside @_implements conflicts with SwiftLint comma rule
    // swift-format-ignore
    /// Iterable's span witness: wraps the scalar slice walker in the generator materialize adapter.
    @inlinable
    @_lifetime(borrow self)
    @_implements(Iterable, makeIterator())
    public borrowing func iterableMakeIterator() -> Iterator_Primitive.Iterator.Materializing<Iterator> {
        Iterator_Primitive.Iterator.Materializing(Iterator(base: base, start: _index, end: _upper))
    }

    /// Returns a scalar iterator over the slice's remaining elements (serves Swift.Sequence / Collection).
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        Iterator(base: base, start: _index, end: _upper)
    }
}

// MARK: - Collection.Protocol

extension Input.Slice: Collection.`Protocol`
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    /// The position of the first element in the slice (the current cursor position).
    @inlinable
    public var startIndex: Index_Primitives.Index<Element> { position }

    /// The position one past the last element in the slice.
    @inlinable
    public var endIndex: Index_Primitives.Index<Element> { _total.map(Ordinal.init) }

    /// Accesses the element at the specified position.
    @inlinable
    public subscript(position: Index_Primitives.Index<Element>) -> Element {
        base[_lower + Index_Primitives.Index<Element>.Count(position)]
    }

    /// Returns the index immediately after the given index.
    @inlinable
    public func index(after i: Index_Primitives.Index<Element>) -> Index_Primitives.Index<Element> {
        // SAFETY: Collection.Protocol's `index(after:)` precondition requires
        // `i < endIndex`, so the +1 step cannot overflow the Ordinal underflow
        // guard. We use do/catch with `i` as sentinel instead of `try!` to keep
        // swift-format happy; the error path is unreachable when the precondition
        // is upheld.
        do throws(Ordinal.Error) {
            return try i + Index_Primitives.Index<Element>.Offset(1)
        } catch {
            return i
        }
    }
}

// MARK: - Swift.Sequence Bridge
//
// Iterator already satisfies IteratorProtocol (has next()).
// Input.Slice already satisfies Sequence (has makeIterator()).
// These empty conformances recover for-in, zip, and Array(...) syntax.

extension Input.Slice.Iterator: IteratorProtocol
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {}

extension Input.Slice: Swift.Sequence
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    /// Returns the exact slice count as the underestimate hint.
    public var underestimatedCount: Int { Int(bitPattern: count) }
}

// MARK: - Swift.Collection Bridge
//
// Input.Slice already provides startIndex, endIndex, subscript(Index),
// index(after:), and subscript(Range<Index>) -> Self. Index<Element>
// is Comparable (Tagged<Element, Ordinal>, Ordinal: Comparable).
// This empty conformance recovers String(decoding:as:) and
// Swift.Collection algorithms.

extension Input.Slice: Swift.Collection
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    /// Sub-sequence type: an `Input.Slice` over the same `Base`.
    public typealias SubSequence = Self

    /// Disambiguates `formIndex(after:)` between the stdlib `Swift.Collection`
    /// default and the institute `Collection.`Protocol`` default — once
    /// `Base.Index == Index<Element>` both match `(inout Index<Element>)`, so a
    /// single concrete witness is required.
    @inlinable
    public func formIndex(after i: inout Index_Primitives.Index<Element>) {
        i = index(after: i)
    }
}

// MARK: - Collection.Slice.Protocol

extension Input.Slice: Collection.Slice.`Protocol`
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    /// Returns a sub-slice spanning the given bounds.
    @inlinable
    public subscript(bounds: Range<Index_Primitives.Index<Element>>) -> Self {
        let absStart = _lower + Index_Primitives.Index<Element>.Count(bounds.lowerBound)
        let absEnd = _lower + Index_Primitives.Index<Element>.Count(bounds.upperBound)
        return Input.Slice(_unchecked: (), base: base, startIndex: absStart, endIndex: absEnd)
    }
}
