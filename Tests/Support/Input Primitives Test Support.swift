public import Index_Primitives
public import Input_Primitives

// MARK: - Fixture Namespace

extension Input {
    /// Test fixtures for `Input.Protocol` and related protocols.
    public enum Fixture {}
}

// MARK: - Source

extension Input.Fixture {
    /// Minimal `Input.Protocol` conformer for testing, backed by an array.
    ///
    /// Forward-only with array-backed storage and an integer position cursor.
    /// Checkpoints are typed `Index<Element>` values (zero-based positions),
    /// enabling backtracking within the slice bounds.
    public struct Source<Element>: Sendable
    where Element: Sendable {
        @usableFromInline
        var _elements: [Element]

        @usableFromInline
        var _position: Index_Primitives.Index<Element>

        /// Creates a fixture source from a copy of the provided elements.
        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
            self._position = .zero
        }
    }
}

// MARK: - Input.Stream.Protocol

extension Input.Fixture.Source: Input.Streaming {
    /// Whether the fixture has been fully consumed.
    @inlinable
    public var isEmpty: Bool {
        Int(bitPattern: _position) >= _elements.count
    }

    /// Consumes and returns the next element.
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

// MARK: - Input.Protocol

extension Input.Fixture.Source: Input.`Protocol` {
    /// Typed position usable as a checkpoint for backtracking.
    public typealias Checkpoint = Index_Primitives.Index<Element>

    @usableFromInline
    var _total: Index_Primitives.Index<Element>.Count {
        do throws(Cardinal.Error) {
            return try Index_Primitives.Index<Element>.Count(_elements.count)
        } catch {
            // SAFETY: Swift.Array.count is always non-negative — the conversion to
            // non-negative Cardinal-backed Count cannot fail. Sentinel for the
            // never-reached path.
            return .zero
        }
    }

    /// The number of remaining elements ahead of the cursor.
    @inlinable
    public var count: Index_Primitives.Index<Element>.Count {
        _total.subtract.saturating(Index_Primitives.Index<Element>.Count(_position))
    }

    /// The current cursor position, capturable as a checkpoint.
    @inlinable
    public var checkpoint: Checkpoint { _position }

    /// The range of valid checkpoint positions for this fixture.
    @inlinable
    public var bounds: ClosedRange<Checkpoint> {
        .zero..._total.map(Ordinal.init)
    }

    /// Moves the cursor to a previously captured checkpoint.
    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        _position = checkpoint
    }

    /// Advances the cursor by the typed count.
    @inlinable
    public mutating func advance(by count: Index_Primitives.Index<Element>.Count) {
        _position += count
    }
}
