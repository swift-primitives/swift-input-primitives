public import Index
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
        var _position: Index.Index<Element>

        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
            self._position = .zero
        }
    }
}

extension Input.Fixture.Source: Input.Streaming {

    @inlinable
    public var isEmpty: Bool {
        Int(bitPattern: _position) >= _elements.count
    }

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = _elements[Int(bitPattern: _position)]
        _position = _position.successor.saturating()
        return element
    }
}

extension Input.Fixture.Source: Input.`Protocol` {

    public typealias Checkpoint = Index.Index<Element>

    @usableFromInline
    var _total: Index.Index<Element>.Count {
        do throws(Cardinal.Error) {
            return try Index.Index<Element>.Count(_elements.count)
        } catch {

            return .zero
        }
    }

    @inlinable
    public var count: Index.Index<Element>.Count {
        _total.subtract.saturating(Index.Index<Element>.Count(_position))
    }

    @inlinable
    public var checkpoint: Checkpoint { _position }

    @inlinable
    public var bounds: ClosedRange<Checkpoint> {
        .zero..._total.map(Ordinal.init)
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        _position = checkpoint
    }

    @inlinable
    public mutating func advance(by count: Index.Index<Element>.Count) {
        _position += count
    }
}
