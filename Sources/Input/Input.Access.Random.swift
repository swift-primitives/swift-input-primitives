extension Input.Access {

    public protocol Random<Element>: Input.`Protocol`, ~Copyable {

        subscript(offset offset: Int) -> Element { get }
    }
}

extension Input.Access.Random where Self: ~Copyable, Element: Copyable {

    @inlinable
    public func element(
        at offset: Int
    ) throws(Input.Access.Error<Element>) -> Element {
        let count = self.count
        guard offset >= .zero && offset < count else {
            throw .outOfBounds(offset: offset, count: count)
        }
        return self[offset: offset]
    }
}

extension Input.Access.Random where Self: ~Copyable, Element: Equatable {

    @inlinable
    public func starts<Prefix: Swift.Collection>(with prefix: Prefix) -> Bool
    where Prefix.Element == Element {

        let prefixCount = prefix.count
        guard prefixCount <= count else { return false }
        for (offset, element) in prefix.enumerated() {
            if self[offset: offset] != element { return false }
        }
        return true
    }

    #if compiler(>=6.4)

        @inlinable
        public func starts(with element: consuming Element) -> Bool {
            !isEmpty && self[offset: 0] == element
        }
    #else

        @inlinable
        public func starts(with element: Element) -> Bool {
            !isEmpty && self[offset: 0] == element
        }
    #endif
}
