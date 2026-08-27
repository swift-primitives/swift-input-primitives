public import Index
public import Property

extension Input.Access {

    public protocol Random<Element>: Input.`Protocol`, ~Copyable {

        subscript(offset offset: Index<Element>.Offset) -> Element { get }
    }
}

extension Input.Access.Random where Self: ~Copyable {

    @inlinable
    public var access: Property<Input.Access, Self>.Inout {
        mutating _read {
            yield Property.Inout(&self)
        }
    }
}

extension Property.Inout
where Tag == Input.Access, Base: Input.Access.Random & ~Copyable, Base.Element: Copyable {

    @inlinable
    public func element(
        at offset: Index<Base.Element>.Offset
    ) throws(Input.Access.Error<Base.Element>) -> Base.Element {
        let count = base.value.count
        guard offset >= .zero && offset < count else {
            throw .outOfBounds(offset: offset, count: count)
        }
        return base.value[offset: offset]
    }
}

extension Property.Inout
where Tag == Input.Access, Base: Input.Access.Random & ~Copyable, Base.Element: Equatable {

    @inlinable
    public func starts<Prefix: Swift.Collection>(with prefix: Prefix) -> Bool
    where Prefix.Element == Base.Element {

        let prefixCount: Index<Base.Element>.Count
        do throws(Cardinal.Error) {
            prefixCount = try Index<Base.Element>.Count(prefix.count)
        } catch {
            prefixCount = .zero
        }
        guard prefixCount <= base.value.count else { return false }
        for (offset, element) in prefix.enumerated() {
            if base.value[offset: Index<Base.Element>.Offset(offset)] != element { return false }
        }
        return true
    }

    #if compiler(>=6.4)

        @inlinable
        public func starts(with element: consuming Base.Element) -> Bool {
            !base.value.isEmpty && base.value[offset: Index<Base.Element>.Offset(0)] == element
        }
    #else

        @inlinable
        public func starts(with element: Base.Element) -> Bool {
            !base.value.isEmpty && base.value[offset: Index<Base.Element>.Offset(0)] == element
        }
    #endif
}
