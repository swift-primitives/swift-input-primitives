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
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Hash.`Protocol` & Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{
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

extension Input.Slice: Swift.Hashable
where
    Base: Collection.`Protocol` & Copyable, Base.Element: Hash.`Protocol` & Copyable,
    Base.Index == Index_Primitives.Index<Base.Element>
{}
