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

// MARK: - Iterator

extension Input.Slice where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable {
    /// Iterator over the elements of an `Input.Slice`.
    ///
    /// Walks the underlying base collection from `sliceStart` to `sliceEnd`.
    /// Uses an array buffer for `nextSpan` to provide contiguous span
    /// access over index-based collection elements.
    ///
    /// - Note: Uses `_spanBuffer` array accumulation. When the base collection
    ///   provides a contiguous iterator, delegation could eliminate the buffer.
    public struct CollectionIterator: Sequence.Iterator.`Protocol` {
        public typealias Element = Base.Element

        @usableFromInline let base: Base
        @usableFromInline let sliceEnd: Base.Index
        @usableFromInline var current: Base.Index
        @usableFromInline var _spanBuffer: [Base.Element] = []

        @inlinable
        init(base: Base, start: Base.Index, end: Base.Index) {
            self.base = base
            self.sliceEnd = end
            self.current = start
        }

        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Base.Element> {
            _spanBuffer.removeAll(keepingCapacity: true)
            var remaining = Int(maximumCount.rawValue)
            while remaining > 0, current < sliceEnd {
                _spanBuffer.append(base[current])
                current = base.index(after: current)
                remaining -= 1
            }
            return _spanBuffer.span
        }

        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Base.Element? {
            guard current < sliceEnd else { return nil }
            let element = base[current]
            current = base.index(after: current)
            return element
        }
    }
}

// MARK: - Sequence.Protocol

extension Input.Slice: Sequence.`Protocol`
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable {
    public typealias Iterator = CollectionIterator

    @inlinable
    public borrowing func makeIterator() -> CollectionIterator {
        CollectionIterator(base: base, start: rawIndex, end: sliceEnd)
    }
}

// MARK: - Collection.Protocol

extension Input.Slice: Collection.`Protocol`
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable {
    @inlinable
    public var startIndex: Index_Primitives.Index<Element> { position }

    @inlinable
    public var endIndex: Index_Primitives.Index<Element> { totalCount.map(Ordinal.init) }

    @inlinable
    public subscript(position: Index_Primitives.Index<Element>) -> Element {
        base[sliceStart + Index_Primitives.Index<Element>.Count(position)]
    }

    @inlinable
    public func index(after i: Index_Primitives.Index<Element>) -> Index_Primitives.Index<Element> {
        try! i + Index_Primitives.Index<Element>.Offset(1)
    }
}

// MARK: - Swift.Sequence Bridge
//
// CollectionIterator already satisfies IteratorProtocol (has next()).
// Input.Slice already satisfies Sequence (has makeIterator()).
// These empty conformances recover for-in, zip, and Array(...) syntax.

extension Input.Slice.CollectionIterator: IteratorProtocol
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable {}

extension Input.Slice: Swift.Sequence
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable {
    /// Disambiguates `underestimatedCount` between the default provided by
    /// `Sequence.Protocol+Swift.Sequence` and `Swift.Sequence` itself.
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
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable {
    public typealias SubSequence = Self
}

// MARK: - Collection.Slice.Protocol

extension Input.Slice: Collection.Slice.`Protocol`
where Base: Collection.`Protocol` & Copyable, Base.Element: Copyable {
    @inlinable
    public subscript(bounds: Range<Index_Primitives.Index<Element>>) -> Self {
        let absStart = sliceStart + Index_Primitives.Index<Element>.Count(bounds.lowerBound)
        let absEnd = sliceStart + Index_Primitives.Index<Element>.Count(bounds.upperBound)
        return Input.Slice(__unchecked: (), base: base, startIndex: absStart, endIndex: absEnd)
    }
}
