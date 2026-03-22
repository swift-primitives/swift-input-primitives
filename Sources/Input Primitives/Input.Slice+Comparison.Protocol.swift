//
//  Input.Slice+Comparison.Protocol.swift
//  swift-input-primitives
//
//  Lexicographic ordering for Input.Slice.
//

public import Collection_Primitives
internal import Comparison_Primitives

extension Input.Slice: Comparison.`Protocol`
where Base: Collection.`Protocol` & Copyable, Base.Element: Comparison.`Protocol` & Copyable {
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
