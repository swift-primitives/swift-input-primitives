//
//  Input.Slice+Hash.Protocol.swift
//  swift-input-primitives
//
//  Hash conformance for Input.Slice.
//

public import Collection_Primitives
public import Hash_Primitives

extension Input.Slice: Hash.`Protocol`
where Base: Collection.`Protocol` & Copyable, Base.Element: Hash.`Protocol` & Copyable {
    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        let selfCopy = copy self
        for element in selfCopy {
            element.hash(into: &hasher)
        }
    }
}
