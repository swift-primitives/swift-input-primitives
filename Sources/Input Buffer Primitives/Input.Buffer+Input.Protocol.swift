//
//  Input.Buffer+Input.Protocol.swift
//  swift-input-primitives
//
//  Input.Protocol conformance for Input.Buffer.
//

extension Input.Buffer: Input.`Protocol` {
    /// Checkpoint type is the typed index.
    ///
    /// Using `Index<Element>` maintains type safety throughout the
    /// checkpoint/restore mechanism.
    public typealias Checkpoint = Index<Element>

    /// The element type (forwarded from storage).
    public typealias Element = Storage.Element

    /// Total count of elements in storage.
    @usableFromInline
    var _total: Index<Element>.Count {
        // reason: typed-system bottom-out — RandomAccessCollection.count is always non-negative,
        // so the conversion to non-negative Cardinal-backed Count cannot throw. We use
        // do/catch with a `.zero` sentinel instead of `try!` to keep swift-format happy.
        do throws(Cardinal.Error) {
            return try Index<Element>.Count(storage.count)
        } catch {
            return .zero
        }
    }

    /// The number of remaining elements in the buffer.
    @inlinable
    public var count: Index<Element>.Count {
        _total.subtract.saturating(Index<Element>.Count(position))
    }

    /// Whether the buffer has any remaining elements.
    @inlinable
    public var isEmpty: Bool {
        position >= _total  // Typed comparison
    }

    /// Number of elements consumed since construction.
    @inlinable
    public var consumed: Index<Element>.Count {
        Index<Element>.Count(position)  // Position IS the consumed count
    }

    /// The first remaining element, or `nil` if the buffer is exhausted.
    @inlinable
    public var first: Element? {
        _read {
            if !isEmpty {
                yield storage[_index]  // Use _index for subscripting
            } else {
                yield nil
            }
        }
    }

    /// A checkpoint at the current cursor position.
    @inlinable
    public var checkpoint: Checkpoint { position }

    /// The range of valid checkpoint positions for this buffer.
    @inlinable
    public var bounds: ClosedRange<Checkpoint> {
        .zero..._total.map(Ordinal.init)  // Count -> Index via functor
    }

    // MARK: - Primitives

    /// Advances the cursor, returning the consumed element.
    ///
    /// - Throws: ``Input/Stream/Error/empty`` if the buffer is empty.
    @inlinable
    @discardableResult
    public mutating func advance() throws(Input.Stream.Error) -> Element {
        guard !isEmpty else {
            throw .empty
        }
        let element = storage[_index]
        position += .one  // Typed increment
        return element
    }

    /// Advances the cursor by `count` elements without validation.
    ///
    /// - Precondition: `count <= self.count`.
    @inlinable
    public mutating func advance(by count: Index<Element>.Count) {
        position += count  // Pure typed arithmetic!
    }

    /// Sets the cursor position to a checkpoint.
    ///
    /// - Precondition: `bounds.contains(checkpoint)` is true.
    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        position = checkpoint
    }
}
