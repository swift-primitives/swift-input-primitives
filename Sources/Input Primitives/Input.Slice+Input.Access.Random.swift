//
//  Input.Slice+Input.Access.Random.swift
//  swift-input-primitives
//
//  Input.Access.Random conformance for Input.Slice over RandomAccessCollection.
//

import Index_Primitives
public import Collection_Primitives

extension Input.Slice: Input.Access.Random where Base: Input.Access.Random {
    @inlinable
    public subscript(
        offset offset: Index<Element>.Offset
    ) -> Element {
        base[base.index(rawIndex, offsetBy: offset)]
    }
}
