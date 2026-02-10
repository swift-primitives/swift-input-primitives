//
//  Input.Slice.swift
//  swift-input-primitives
//
//  Zero-copy cursor over a collection.
//

public import Collection_Primitives

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
    /// `Slice` is `Sendable` when `Base` and `Base.Index` are `Sendable`.
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
    public struct Slice<Base: Collection.`Protocol`>: Sendable
    where Base: Sendable, Base.Index: Sendable {
        /// The underlying collection.
        @usableFromInline
        let base: Base

        /// The raw start index of the slice in base (fixed at construction).
        @usableFromInline
        let sliceStart: Base.Index

        /// The raw end index of the slice in base (fixed at construction).
        @usableFromInline
        let sliceEnd: Base.Index

        /// The current position as a typed index (relative to slice start).
        ///
        /// Primary representation for typed arithmetic (`position + count`).
        @usableFromInline
        var position: Index<Base.Element>

        /// The raw current index for subscripting.
        ///
        /// Derives `Base.Index` from typed position. O(1) for RandomAccessCollection.
        @inlinable
        var rawIndex: Base.Index {
            sliceStart + Index<Base.Element>.Count(position)
        }

        /// Creates a slice cursor over the entire collection.
        ///
        /// - Parameter base: The collection to wrap.
        @inlinable
        public init(_ base: Base) {
            self.base = base
            self.sliceStart = base.startIndex
            self.sliceEnd = base.endIndex
            self.position = .zero
        }

        /// Creates a slice cursor with explicit bounds.
        ///
        /// - Parameters:
        ///   - base: The collection to wrap.
        ///   - startIndex: The starting index.
        ///   - endIndex: The ending index.
        /// - Throws: ``Error/invalidBounds(startIndex:endIndex:)`` if
        ///   `startIndex > endIndex`.
        @inlinable
        public init(
            base: Base,
            startIndex: Base.Index,
            endIndex: Base.Index
        ) throws(Input.Slice<Base>.Error) {
            guard startIndex <= endIndex else {
                throw .invalidBounds(
                    startIndex: startIndex,
                    endIndex: endIndex
                )
            }
            self.base = base
            self.sliceStart = startIndex
            self.sliceEnd = endIndex
            self.position = .zero
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
            self.base = base
            self.sliceStart = startIndex
            self.sliceEnd = endIndex
            self.position = .zero
        }
    }
}
