//
//  Input.Slice+Input.Access.Random.swift
//  swift-input-primitives
//
//  Input.Access.Random conformance for Input.Slice over RandomAccessCollection.
//

extension Input.Slice: Input.Access.Random where Base: Swift.RandomAccessCollection {
    @inlinable
    public subscript(offset offset: Index<Element>.Offset) -> Element {
        base[base.index(startIndex, offsetBy: offset.rawValue)]
    }
}
