public import Affine_Arithmetic
public import Affine_Tagged
public import Collection_Protocol
public import Index
public import Ordinal_Protocol
public import Tagged

internal import Ordinal
internal import Ordinal_Error

extension Input.Slice: Input.Access.Random
where
    Base: Collection.`Protocol`, Base.Element: Copyable,
    Base.Index == Index::Index<Base.Element>
{

    @inlinable
    public subscript(
        offset offset: Index::Index<Element>.Offset
    ) -> Element {

        do throws(Ordinal.Error) {
            return try base[_index + offset]
        } catch {
            return base[_index]
        }
    }
}
