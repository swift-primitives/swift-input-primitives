extension Input.Buffer: Input.Access.Random {

    @inlinable
    public subscript(offset offset: Int) -> Element {
        storage[storage.index(_index, offsetBy: offset)]
    }
}
