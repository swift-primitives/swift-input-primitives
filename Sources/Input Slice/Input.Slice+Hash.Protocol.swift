public import Collection_Protocol
public import Hash_Protocol
public import Index

extension Input.Slice: Swift.Hashable
where
    Base: Collection.`Protocol` & Copyable,
    Base.Element: Hash::Hash.`Protocol` & Copyable,
    Base.Index == Index::Index<Base.Element>
{

    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        let selfCopy = copy self
        for element in selfCopy {
            element.hash(into: &hasher)
        }
    }
}

extension Input.Slice: Hash::Hash.`Protocol`
where
    Base: Collection.`Protocol` & Copyable,
    Base.Element: Hash::Hash.`Protocol` & Copyable,
    Base.Index == Index::Index<Base.Element>
{}
