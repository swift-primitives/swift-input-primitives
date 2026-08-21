extension Input.Stream {

    public protocol `Protocol`: ~Copyable {

        associatedtype Element: ~Copyable & Escapable

        var isEmpty: Bool { get }

        @discardableResult
        mutating func advance() throws(Input.Stream.Error) -> Element
    }
}

extension Input.Stream.`Protocol` where Self: ~Copyable {

    @inlinable
    public mutating func next() -> Element? {
        guard !isEmpty else { return nil }

        do throws(Input.Stream.Error) {
            return try advance()
        } catch {
            return nil
        }
    }
}

extension Input {

    public typealias Streaming = Input.Stream.`Protocol`
}
