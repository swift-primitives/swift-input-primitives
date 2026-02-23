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
where Base: Collection.`Protocol`, Base.Element: Copyable {}

extension Input.Slice: Input.`Protocol`
where Base: Collection.`Protocol`, Base.Element: Copyable {
    public typealias Element = Base.Element

    /// Checkpoint type is the typed index (position within slice).
    public typealias Checkpoint = Index_Primitives.Index<Element>

    /// Total count of elements in the slice.
    @inlinable
    var totalCount: Index_Primitives.Index<Element>.Count {
        try! sliceStart.distance.forward(to: sliceEnd)
    }

    @inlinable
    public var isEmpty: Bool {
        position >= totalCount  // Typed comparison
    }

    @inlinable
    public var count: Index_Primitives.Index<Element>.Count {
        totalCount.subtract.saturating(Index_Primitives.Index<Element>.Count(position))
    }

    @inlinable
    public var first: Element? {
        _read {
            if !isEmpty {
                yield base[rawIndex]  // Use rawIndex for subscripting
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
    public var checkpointRange: ClosedRange<Checkpoint> {
        .zero...totalCount.map(Ordinal.init)  // Count -> Index via functor
    }

    // MARK: - Primitives

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = base[rawIndex]
        position = position + .one  // Typed increment
        return element
    }

    @inlinable
    public mutating func advance(by count: Index_Primitives.Index<Element>.Count) {
        position = position + count  // Pure typed arithmetic!
    }

    @inlinable
    public mutating func setPosition(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
