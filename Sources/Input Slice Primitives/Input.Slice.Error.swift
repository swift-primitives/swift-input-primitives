public import Collection_Primitives
public import Index_Primitives

extension Input.Slice
where Base: Collection.`Protocol`, Base.Index == Index_Primitives.Index<Base.Element> {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidBounds(startIndex: Base.Index, endIndex: Base.Index)
    }
}

extension Input.Slice
where Base: Collection.`Protocol`, Base.Index == Index_Primitives.Index<Base.Element> {

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
        self.init(
            _base: base,
            start: Int(bitPattern: startIndex),
            end: Int(bitPattern: endIndex),
            position: 0
        )
    }
}
