public import Collection_Primitives
public import Index_Primitives

extension Input {

    public struct Slice<Base: ~Copyable>: ~Copyable {

        @usableFromInline
        let base: Base

        @usableFromInline
        let _start: Int

        @usableFromInline
        let _end: Int

        @usableFromInline
        var _position: Int

        @usableFromInline
        init(_base: consuming Base, start: Int, end: Int, position: Int) {
            self.base = _base
            self._start = start
            self._end = end
            self._position = position
        }
    }
}

extension Input.Slice: Copyable where Base: Copyable {}

extension Input.Slice: Sendable where Base: Sendable {}

extension Input.Slice
where Base: Collection.`Protocol`, Base.Index == Index_Primitives.Index<Base.Element> {

    @usableFromInline
    var _lower: Base.Index {
        Base.Index(_unchecked: Ordinal(UInt(bitPattern: _start)))
    }

    @usableFromInline
    var _upper: Base.Index {
        Base.Index(_unchecked: Ordinal(UInt(bitPattern: _end)))
    }

    @usableFromInline
    var position: Index_Primitives.Index<Base.Element> {
        @inline(always) get {
            Index_Primitives.Index<Base.Element>(
                _unchecked: Ordinal(UInt(bitPattern: _position))
            )
        }
        @inline(always) set {
            _position = Int(bitPattern: newValue)
        }
    }

    @usableFromInline
    var _index: Base.Index {
        _lower + Index_Primitives.Index<Base.Element>.Count(position)
    }
}

extension Input.Slice
where Base: Collection.`Protocol`, Base.Index == Index_Primitives.Index<Base.Element> {

    @inlinable
    public init(_ base: Base) {
        self.init(
            _base: base,
            start: Int(bitPattern: base.startIndex),
            end: Int(bitPattern: base.endIndex),
            position: 0
        )
    }

    @inlinable
    public init(
        _unchecked: Void,
        base: Base,
        startIndex: Base.Index,
        endIndex: Base.Index
    ) {
        self.init(
            _base: base,
            start: Int(bitPattern: startIndex),
            end: Int(bitPattern: endIndex),
            position: 0
        )
    }
}
