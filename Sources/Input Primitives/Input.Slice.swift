//
//  Input.Slice.swift
//  swift-input-primitives
//
//  Zero-copy cursor over a collection.
//

public import Collection_Primitives
public import Index_Primitives

extension Input {
    /// Zero-copy cursor over a collection.
    ///
    /// Provides O(1) slicing by tracking start/end indices into the
    /// underlying collection. The collection is shared (not copied).
    ///
    /// ## Invariants
    ///
    /// - `startIndex <= endIndex`
    /// - `startIndex` and `endIndex` are valid indices of `base`
    /// - `count == base.distance(from: startIndex, to: endIndex)`
    ///
    /// ## Sendable
    ///
    /// `Slice` is `Sendable` when `Base` is `Sendable`.
    ///
    /// ## Runtime Bug Workaround
    ///
    /// The struct-level generic constraint uses `Sendable` instead of
    /// `Collection.Protocol` to avoid a Swift runtime SIGSEGV during
    /// generic metadata instantiation. The `Collection.Protocol` constraint
    /// is applied in conditional extensions. This is a workaround for a
    /// Swift compiler/runtime bug where `~Copyable` protocol constraints
    /// on struct-level generic parameters cause NULL pointer dereferences
    /// in `swift_isClassType` when the struct is used as a stored type
    /// argument (e.g. `[Input.Slice<...>]`, `Parser.Always<Input.Slice<...>, ...>`).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
    /// var input = Input.Slice(bytes[...])
    ///
    /// let checkpoint = input.checkpoint
    /// let first = input.removeFirst()  // 0x48
    ///
    /// input.restore(to: checkpoint)
    /// assert(input.first == 0x48)
    /// ```
    public struct Slice<Base: Sendable & ~Copyable>: ~Copyable, Sendable {
        /// The underlying collection.
        @usableFromInline
        let base: Base

        /// Raw start offset (workaround: stores Int instead of Base.Index).
        @usableFromInline
        let _start: Int

        /// Raw end offset (workaround: stores Int instead of Base.Index).
        @usableFromInline
        let _end: Int

        /// Raw position offset (workaround: stores Int instead of Index<Base.Element>).
        @usableFromInline
        var _position: Int

        /// Internal memberwise init for raw storage.
        @usableFromInline
        init(_base: consuming Base, start: Int, end: Int, position: Int) {
            self.base = _base
            self._start = start
            self._end = end
            self._position = position
        }
    }
}

// MARK: - Conditional Copyable

extension Input.Slice: Copyable where Base: Copyable {}

// MARK: - Typed Accessors

extension Input.Slice where Base: Collection.`Protocol` {
    /// The raw start index of the slice in base (fixed at construction).
    @usableFromInline
    var sliceStart: Base.Index {
        Base.Index(__unchecked: (), Ordinal(UInt(bitPattern: _start)))
    }

    /// The raw end index of the slice in base (fixed at construction).
    @usableFromInline
    var sliceEnd: Base.Index {
        Base.Index(__unchecked: (), Ordinal(UInt(bitPattern: _end)))
    }

    /// The current position as a typed index (relative to slice start).
    @usableFromInline
    var position: Index_Primitives.Index<Base.Element> {
        @inline(always) get {
            Index_Primitives.Index<Base.Element>(
                __unchecked: (), Ordinal(UInt(bitPattern: _position))
            )
        }
        @inline(always) set {
            _position = Int(bitPattern: newValue)
        }
    }

    /// The raw current index for subscripting.
    ///
    /// Derives `Base.Index` from typed position. O(1) for RandomAccessCollection.
    @inlinable
    var rawIndex: Base.Index {
        sliceStart + Index_Primitives.Index<Base.Element>.Count(position)
    }
}

// MARK: - Public Initializers

extension Input.Slice where Base: Collection.`Protocol`, Base.Index: Sendable {
    /// Creates a slice cursor over the entire collection.
    ///
    /// - Parameter base: The collection to wrap.
    @inlinable
    public init(_ base: Base) {
        self.init(
            _base: base,
            start: Int(bitPattern: base.startIndex),
            end: Int(bitPattern: base.endIndex),
            position: 0
        )
    }

    /// Creates a slice cursor with explicit bounds without validation.
    ///
    /// - Parameters:
    ///   - base: The collection to wrap.
    ///   - startIndex: The starting index.
    ///   - endIndex: The ending index.
    /// - Precondition: `startIndex <= endIndex` and both are valid indices.
    @inlinable
    public init(
        __unchecked: Void,
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
