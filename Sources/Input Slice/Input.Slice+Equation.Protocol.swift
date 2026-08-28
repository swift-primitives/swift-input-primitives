public import Collection
internal import Equation
public import Index

extension Input.Slice: Equation.`Protocol`
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Equation.`Protocol` & Copyable,
    Base.Index == Index.Index<Base.Element>
{

    @inlinable
    @_disfavoredOverload
    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (l, r) in zip(lhs, rhs) {
            if !(l == r) { return false }
        }
        return true
    }
}
