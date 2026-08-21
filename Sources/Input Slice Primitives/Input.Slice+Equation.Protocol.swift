public import Collection_Primitives
internal import Equation_Primitives
public import Index_Primitives

extension Input.Slice: Equation.`Protocol`
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Equation.`Protocol` & Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
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
