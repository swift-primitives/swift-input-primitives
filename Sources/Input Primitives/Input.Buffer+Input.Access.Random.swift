//
//  Input.Buffer+Input.Access.Random.swift
//  swift-input-primitives
//
//  Input.Access.Random conformance for Input.Buffer.
//

extension Input.Buffer: Input.Access.Random {
    @inlinable
    public subscript(offset offset: Int) -> Element {
        storage[position + offset]
    }
}
