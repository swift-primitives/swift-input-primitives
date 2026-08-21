public import Collection_Primitives
public import Index_Primitives

extension Input.Slice: Input.Access.Random
where
    Base: Collection.`Protocol`, Base.Element: Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{

    @inlinable
    public subscript(
        offset offset: Index_Primitives.Index<Element>.Offset
    ) -> Element {

        do throws(Ordinal.Error) {
            return try base[_index + offset]
        } catch {
            return base[_index]
        }
    }
}
