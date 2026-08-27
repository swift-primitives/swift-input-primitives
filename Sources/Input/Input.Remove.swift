extension Input {

    public enum Remove {}
}

extension Input.Streaming where Self: ~Copyable {

    @inlinable
    @discardableResult
    public mutating func removeFirst() throws(Input.Remove.Error<Element>) -> Element {
        do throws(Input.Stream.Error) {
            return try advance()
        } catch {
            throw .empty
        }
    }

    @inlinable
    @discardableResult
    public mutating func removeFirst(__unchecked: Void) -> Element {

        do throws(Input.Stream.Error) {
            return try advance()
        } catch {
            fatalError("removeFirst(__unchecked:) called on empty input — precondition violated")
        }
    }
}

extension Input.`Protocol` where Self: ~Copyable {

    @inlinable
    public mutating func removeFirst(
        _ count: Int
    ) throws(Input.Remove.Error<Element>) {
        let available = self.count
        guard count >= 0 && count <= available else {
            throw .insufficientElements(requested: count, available: available)
        }
        advance(by: count)
    }

    @inlinable
    public mutating func removeFirst(__unchecked: Void, _ count: Int) {
        advance(by: count)
    }
}
