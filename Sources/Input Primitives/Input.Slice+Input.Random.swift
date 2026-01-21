//
//  Input.Slice+Input.Random.swift
//  swift-input-primitives
//
//  Input.Random conformance for Input.Slice over RandomAccessCollection.
//

extension Input.Slice: Input.Random where Base: RandomAccessCollection {
    @inlinable
    public subscript(offset offset: Int) -> Element {
        base[base.index(startIndex, offsetBy: offset)]
    }
}
