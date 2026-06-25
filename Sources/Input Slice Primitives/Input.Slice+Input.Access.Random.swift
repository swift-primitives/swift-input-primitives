//
//  Input.Slice+Input.Access.Random.swift
//  swift-input-primitives
//
//  Input.Access.Random conformance for Input.Slice.
//

public import Collection_Primitives
public import Index_Primitives

extension Input.Slice: Input.Access.Random
where Base: Collection.`Protocol`, Base.Element: Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    /// Accesses the element at the given offset from the current position.
    ///
    /// - Precondition: `offset >= 0 && offset < count`.
    @inlinable
    public subscript(
        offset offset: Index_Primitives.Index<Element>.Offset
    ) -> Element {
        // SAFETY: subscript is unchecked per stdlib convention. The caller's
        // precondition `offset >= 0 && offset < count` ensures the Index addition
        // cannot underflow. We use do/catch with `base[_index]` as sentinel
        // instead of `try!` to keep swift-format happy; the error path is
        // unreachable when the precondition is upheld.
        do throws(Ordinal.Error) {
            return try base[_index + offset]
        } catch {
            return base[_index]
        }
    }
}
