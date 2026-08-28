public import Cardinal
public import Index
public import Ordinal_Protocol
public import Property
public import Property_Inout
public import Tagged

extension Input {

    public enum Remove {}
}

extension Input.Streaming where Self: ~Copyable {

    @inlinable
    public var remove: Property::Property<Input.Remove, Self>.Inout {
        mutating _read {
            yield Property::Property<Input.Remove, Self>.Inout(&self)
        }
    }
}

extension Property::Property.Inout
where Tag == Input.Remove, Base: Input.Streaming & ~Copyable {

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

extension Property::Property.Inout
where Tag == Input.Remove, Base: Input.`Protocol` & ~Copyable {

    @inlinable
    public func first(
        _ count: Index::Index<Base.Element>.Count
    ) throws(Input.Remove.Error<Base.Element>) {
        let available = base.value.count
        guard count <= available else {
            throw .insufficientElements(requested: count, available: available)
        }
        base.value.advance(by: count)
    }

    @inlinable
    public func first(__unchecked: Void, _ count: Index::Index<Base.Element>.Count) {
        base.value.advance(by: count)
    }
}
