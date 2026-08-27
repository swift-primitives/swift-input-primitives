public import Index

extension Input.Buffer: Input.Access.Random {

    @inlinable
    public subscript(offset offset: Index<Element>.Offset) -> Element {
        storage[storage.index(_index, offsetBy: offset)]
    }
}
