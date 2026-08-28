public import Collection
internal import Comparison
public import Index

extension Input.Slice: Comparison.`Protocol`
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Comparison.`Protocol` & Copyable,
    Base.Index == Index.Index<Base.Element>
{

    @inlinable
    @_disfavoredOverload
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        for (l, r) in zip(lhs, rhs) {
            if l < r { return true }
            if r < l { return false }
        }
        return lhs.count < rhs.count
    }
}
