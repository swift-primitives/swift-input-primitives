public import Collection
public import Index

extension Input.Slice: Input.Access.Random
where
    Base: Collection.`Protocol`, Base.Element: Copyable,
    Base.Index == Index.Index<Base.Element>
{

    @inlinable
    public subscript(
        offset offset: Index.Index<Element>.Offset
    ) -> Element {

        do throws(Ordinal.Error) {
            return try base[_index + offset]
        } catch {
            return base[_index]
        }
    }
}
