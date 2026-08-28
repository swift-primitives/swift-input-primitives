public import Collection
internal import Hash
public import Index

extension Input.Slice: Hash.`Protocol`
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Hash.`Protocol` & Copyable,
    Base.Index == Index.Index<Base.Element>
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

extension Input.Slice: Swift.Hashable
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Hash.`Protocol` & Copyable,
    Base.Index == Index.Index<Base.Element>
{}
