extension Input {

    public enum Remove {}
}

extension Input.Streaming where Self: ~Copyable {

    @inlinable
    public var remove: Property<Input.Remove, Self>.Inout {
        mutating _read {
            yield Property.Inout(&self)
        }
    }
}

extension Property.Inout where Tag == Input.Remove, Base: Input.Streaming & ~Copyable {

    @inlinable
    @discardableResult
    public func first() throws(Input.Remove.Error<Base.Element>) -> Base.Element {
        do throws(Input.Stream.Error) {
            return try base.value.advance()
        } catch {
            throw .empty
        }
    }

    @inlinable
    @discardableResult
    public func first(__unchecked: Void) -> Base.Element {

        do throws(Input.Stream.Error) {
            return try base.value.advance()
        } catch {
            fatalError("first(__unchecked:) called on empty input — precondition violated")
        }
    }
}

extension Property.Inout where Tag == Input.Remove, Base: Input.`Protocol` & ~Copyable {

    @inlinable
    public func first(_ count: Index<Base.Element>.Count) throws(Input.Remove.Error<Base.Element>) {
        let available = base.value.count
        guard count <= available else {
            throw .insufficientElements(requested: count, available: available)
        }
        base.value.advance(by: count)
    }

    @inlinable
    public func first(__unchecked: Void, _ count: Index<Base.Element>.Count) {
        base.value.advance(by: count)
    }
}
