//
//  Input.Slice+Input.Protocol.swift
//  swift-input-primitives
//
//  Input.Protocol conformance for Input.Slice.
//

public import Collection_Primitives
public import Index_Primitives

// Explicit inherited protocol conformance required for conditional conformance.
extension Input.Slice: Input.Streaming
where Base: Collection.`Protocol`, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {}

extension Input.Slice: Input.`Protocol`
where Base: Collection.`Protocol`, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    /// The element type yielded by the slice (forwarded from `Base`).
    public typealias Element = Base.Element

    /// Checkpoint type is the typed index (position within slice).
    public typealias Checkpoint = Index_Primitives.Index<Element>

    /// Total count of elements in the slice.
    @usableFromInline
    var _total: Index_Primitives.Index<Element>.Count {
        // reason: typed-system bottom-out — slice invariant `_lower <= _upper`
        // ensures forward distance is non-negative and cannot throw. We use do/catch
        // with a `.zero` sentinel instead of `try!` to keep swift-format happy.
        do throws(Ordinal.Error) {
            return try _lower.distance.forward(to: _upper)
        } catch {
            return .zero
        }
    }

    /// Whether the slice has any remaining elements.
    @inlinable
    public var isEmpty: Bool {
        position >= _total  // Typed comparison
    }

    /// The number of remaining elements in the slice.
    @inlinable
    public var count: Index_Primitives.Index<Element>.Count {
        _total.subtract.saturating(Index_Primitives.Index<Element>.Count(position))
    }

    /// Number of elements consumed since construction.
    @inlinable
    public var consumed: Index_Primitives.Index<Element>.Count {
        Index_Primitives.Index<Element>.Count(position)  // Position IS the consumed count
    }

    /// The first remaining element, or `nil` if the slice is exhausted.
    @inlinable
    public var first: Element? {
        _read {
            if !isEmpty {
                yield base[_index]  // Use _index for subscripting
            } else {
                yield nil
            }
        }
    }

    /// A checkpoint at the current cursor position.
    @inlinable
    public var checkpoint: Checkpoint {
        position
    }

    /// The range of valid checkpoint positions for this slice.
    @inlinable
    public var bounds: ClosedRange<Checkpoint> {
        .zero..._total.map(Ordinal.init)  // Count -> Index via functor
    }

    // MARK: - Primitives

    /// Advances the cursor, returning the consumed element.
    ///
    /// - Throws: ``Input/Stream/Error/empty`` if the slice is empty.
    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = base[_index]
        position += .one  // Typed increment
        return element
    }

    /// Advances the cursor by `count` elements without validation.
    ///
    /// - Precondition: `count <= self.count`.
    @inlinable
    public mutating func advance(by count: Index_Primitives.Index<Element>.Count) {
        position += count  // Pure typed arithmetic!
    }

    /// Sets the cursor position to a checkpoint.
    ///
    /// - Precondition: `bounds.contains(checkpoint)` is true.
    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
