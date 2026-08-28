public import Cardinal
public import Cardinal_Tagged
public import Index
public import Input
public import Ordinal
public import Ordinal_Protocol
public import Ordinal_Successor
public import Ordinal_Tagged
public import Tagged

internal import Cardinal_Error

extension Input {

    public enum Fixture {}
}

extension Input.Fixture {

    public struct Source<Element>: Sendable
    where Element: Sendable {
        @usableFromInline
        var _elements: [Element]

        @usableFromInline
        var _position: Index::Index<Element>

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
        Int(bitPattern: _position.underlying.rawValue) >= _elements.count
    }

    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = _elements[Int(bitPattern: _position.underlying.rawValue)]
        _position = _position.successor.saturating()
        return element
    }
}

extension Input.Fixture.Source: Input.`Protocol` {

    public typealias Checkpoint = Index::Index<Element>

    @usableFromInline
    var _total: Index::Index<Element>.Count {
        do throws(Cardinal.Error) {
            return try Index::Index<Element>.Count(_elements.count)
        } catch {

            return .zero
        }
    }

    @inlinable
    public var count: Index::Index<Element>.Count {
        _total.subtract.saturating(Index::Index<Element>.Count(_position))
    }

    @inlinable
    public var checkpoint: Checkpoint { _position }

    @inlinable
    public var bounds: ClosedRange<Checkpoint> {
        .zero...Index::Index<Element>(
            _unchecked: Ordinal(_total.underlying.rawValue)
        )
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        _position = checkpoint
    }

    @inlinable
    public mutating func advance(by count: Index::Index<Element>.Count) {
        _position += count
    }
}
