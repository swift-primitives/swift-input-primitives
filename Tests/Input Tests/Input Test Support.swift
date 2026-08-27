public import Input

extension Input {

    public enum Fixture {}
}

extension Input.Fixture {

    public struct Source<Element>: Sendable
    where Element: Sendable {
        @usableFromInline
        var _elements: [Element]

        @usableFromInline
        var _position: Int

        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
            self._position = 0
        }
    }
}

extension Input.Fixture.Source: Input.Streaming {

    @inlinable
    public var isEmpty: Bool {
        _position >= _elements.count
    }

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = _elements[_position]
        _position += 1
        return element
    }
}

extension Input.Fixture.Source: Input.`Protocol` {

    public typealias Checkpoint = Int

    @usableFromInline
    var _total: Int {
        _elements.count
    }

    @inlinable
    public var count: Int {
        _total - _position
    }

    @inlinable
    public var checkpoint: Checkpoint { _position }

    @inlinable
    public var bounds: ClosedRange<Checkpoint> {
        0..._total
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        _position = checkpoint
    }

    @inlinable
    public mutating func advance(by count: Int) {
        _position += count
    }
}
