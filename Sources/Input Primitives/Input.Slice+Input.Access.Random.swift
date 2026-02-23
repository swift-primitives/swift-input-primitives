//
//  Input.Slice+Input.Access.Random.swift
//  swift-input-primitives
//
//  Input.Access.Random conformance for Input.Slice.
//

public import Index_Primitives
public import Collection_Primitives

extension Input.Slice: Input.Access.Random
where Base: Collection.`Protocol`, Base.Element: Copyable {
    @inlinable
    public subscript(
        offset offset: Index_Primitives.Index<Element>.Offset
    ) -> Element {
        base[try! rawIndex + offset]
    }
}
