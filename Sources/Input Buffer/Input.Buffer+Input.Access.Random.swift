public import Affine_Discrete
public import Affine_Tagged
public import Index
public import Input_Access
public import Tagged

extension Input.Buffer: Input.Access.Random {

    @inlinable
    public subscript(offset offset: Index::Index<Element>.Offset) -> Element {
        storage[storage.index(_index, offsetBy: offset.underlying.rawValue)]
    }
}
