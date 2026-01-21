//
//  Input.Buffer+Input.Random.swift
//  swift-input-primitives
//
//  Input.Random conformance for Input.Buffer.
//

extension Input.Buffer: Input.Random {
    @inlinable
    public subscript(offset offset: Int) -> Element {
        storage[position + offset]
    }
}
