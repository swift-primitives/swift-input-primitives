//
//  Input.Slice+Hash.Protocol.swift
//  swift-input-primitives
//
//  Hash conformance for Input.Slice.
//

public import Collection_Primitives
internal import Hash_Primitives
public import Index_Primitives

extension Input.Slice: Hash.`Protocol`
where Base: Collection.`Protocol` & Copyable, Base.Element: Hash.`Protocol` & Copyable, Base.Index == Index_Primitives.Index<Base.Element> {
    /// Feeds the slice's elements into the given hasher in order.
    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        let selfCopy = copy self
        for element in selfCopy {
            element.hash(into: &hasher)
        }
    }
}

// Swift 6.4+: `Hash.Protocol` REFINES `Swift.Hashable`; a conditional conformance to it
// does not synthesize the inherited `Swift.Hashable`, so declare it explicitly (the
// `hash(into:)` witness above satisfies it). Ref: Research/se-0499-…md Addendum (2026-06-01).
#if swift(>=6.4)
    extension Input.Slice: Swift.Hashable
    where Base: Collection.`Protocol` & Copyable, Base.Element: Hash.`Protocol` & Copyable, Base.Index == Index_Primitives.Index<Base.Element> {}
#endif
