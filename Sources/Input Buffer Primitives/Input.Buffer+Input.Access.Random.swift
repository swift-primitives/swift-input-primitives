//
//  Input.Buffer+Input.Access.Random.swift
//  swift-input-primitives
//
//  Input.Access.Random conformance for Input.Buffer.
//

extension Input.Buffer: Input.Access.Random {
    /// Accesses the element at the given offset from the current position.
    ///
    /// - Precondition: `offset >= 0 && offset < count`.
    @inlinable
    public subscript(offset offset: Index<Element>.Offset) -> Element {
        storage[storage.index(_index, offsetBy: offset)]
    }
}
