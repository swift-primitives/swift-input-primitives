//
//  Input.Slice Tests.swift
//  swift-input-primitives
//

import Input_Primitives_Test_Support
import Iterable
import Iterator_Chunk_Primitives
import Sequence_Primitives
import Testing

@testable import Input_Primitives

/// Minimal Collection.Protocol conformer for testing Input.Slice.
private struct TestCollection<Element: Sendable>: Sendable {
    var storage: [Element]
}

// MARK: - TestCollection.Iterator

extension TestCollection {
    struct Iterator {
        var offset: Int
        let storage: [Element]
        var _element: Element? = nil
    }
}

// MARK: - TestCollection.Iterator: Iterator.Chunk.Protocol witnesses

// swiftlint:disable:next workaround_marker_present
// WORKAROUND: dropped the stdlib `IteratorProtocol` conformance from this extension.
// WHY: Swift 6.3.2 (+Asserts, e.g. the Windows CI toolchain) crashes type-checking it —
//      Assertion `getEffects(req).contains(getEffects(witness))` (TypeCheckProtocol.cpp:1311):
//      the chunk protocol's `where Element: Copyable` derived `next() throws(Never)` competes
//      with the non-throwing `IteratorProtocol.next()` requirement and trips an effects check.
//      The conformance was unused by these tests (no stdlib for-in / .next() over the Iterator;
//      Iterable needs only Iterator.Chunk.Protocol, not stdlib IteratorProtocol).
// TRACKING: swift-institute/Issues/swift-issue-typed-throws-never-witness-effects-assertion
// WHEN TO REMOVE: fixed on Swift 6.5-dev — restore `, IteratorProtocol` once the Windows CI
//      toolchain ships a Swift carrying the fix.
extension TestCollection.Iterator: Iterator.Chunk.`Protocol` {
    typealias Failure = Never

    @_lifetime(&self)
    mutating func next(maximumCount: some Carrier.`Protocol`<Cardinal>) -> Span<Element> {
        let ptr = unsafe withUnsafeMutablePointer(to: &_element) { p in
            unsafe UnsafePointer<Element>(
                unsafe UnsafeRawPointer(p).assumingMemoryBound(to: Element.self)
            )
        }
        guard maximumCount.underlying > .zero else {
            let span = unsafe Span(_unsafeStart: ptr, count: 0)
            return unsafe _overrideLifetime(span, mutating: &self)
        }
        guard let value = next() else {
            let span = unsafe Span(_unsafeStart: ptr, count: 0)
            return unsafe _overrideLifetime(span, mutating: &self)
        }
        _element = value
        let span = unsafe Span(_unsafeStart: ptr, count: 1)
        return unsafe _overrideLifetime(span, mutating: &self)
    }

    mutating func next() -> Element? {
        guard offset < storage.count else { return nil }
        let element = storage[offset]
        offset += 1
        return element
    }
}

// MARK: - TestCollection: Collection.Protocol witnesses

extension TestCollection: Collection.`Protocol` {
    var startIndex: Index_Primitives.Index<Element> { .zero }

    var endIndex: Index_Primitives.Index<Element> {
        Index_Primitives.Index<Element>.Count(Cardinal(UInt(storage.count))).map(Ordinal.init)
    }

    subscript(position: Index_Primitives.Index<Element>) -> Element {
        storage[Int(bitPattern: position)]
    }

    func index(after i: Index_Primitives.Index<Element>) -> Index_Primitives.Index<Element> {
        do throws(Ordinal.Error) {
            return try i.successor.exact()
        } catch {
            // SAFETY: Collection.Protocol's `index(after:)` precondition requires
            // `i < endIndex`, so the successor cannot overflow. Sentinel for the
            // never-reached path.
            return endIndex
        }
    }

    borrowing func makeIterator() -> Iterator {
        Iterator(offset: 0, storage: storage)
    }
}

// TestCollection conforms Iterable via the Collection.Protocol: Iterable refine edge
// (its makeIterator above is the witness); no explicit conformance needed.

// MARK: - Test Suite Structure

extension Input {
    @Suite
    enum `Slice Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension Input.`Slice Test`.Unit {
    @Test
    func `init from collection`() {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        let slice = Input.Slice(collection)
        let expectedCount: Index<Int>.Count = 5
        #expect(slice.count == expectedCount)
        #expect(slice.first == 1)
        #expect(!slice.isEmpty)
    }

    @Test
    func `isEmpty returns true for empty slice`() {
        let collection = TestCollection<Int>(storage: [])
        let slice = Input.Slice(collection)
        #expect(slice.isEmpty)
        let expectedCount: Index<Int>.Count = 0
        #expect(slice.count == expectedCount)
        #expect(slice.first == nil)
    }

    @Test
    func `remove.first() consumes element`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [1, 2, 3])
        var slice = Input.Slice(collection)
        let first = try slice.remove.first()
        #expect(first == 1)
        let expectedCount: Index<Int>.Count = 2
        #expect(slice.count == expectedCount)
        #expect(slice.first == 2)
    }

    @Test
    func `remove.first(n) advances by n elements`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var slice = Input.Slice(collection)
        let three: Index<Int>.Count = 3
        try slice.remove.first(three)
        let expectedCount: Index<Int>.Count = 2
        #expect(slice.count == expectedCount)
        #expect(slice.first == 4)
    }

    @Test
    func `checkpoint returns current position`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var slice = Input.Slice(collection)
        _ = try slice.remove.first()
        let cp = slice.checkpoint
        _ = try slice.remove.first()
        #expect(slice.first == 3)
        do throws(Input.Restore.Error) {
            try slice.restore.to(cp)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(slice.first == 2)
    }

    @Test
    func `checkpoint and restore roundtrip`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var slice = Input.Slice(collection)
        let cp = slice.checkpoint
        _ = try slice.remove.first()
        _ = try slice.remove.first()
        let expectedCount3: Index<Int>.Count = 3
        #expect(slice.count == expectedCount3)
        do throws(Input.Restore.Error) {
            try slice.restore.to(cp)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        let expectedCount5: Index<Int>.Count = 5
        #expect(slice.count == expectedCount5)
        #expect(slice.first == 1)
    }

    @Test
    func `subscript offset access`() {
        let collection = TestCollection(storage: [10, 20, 30, 40, 50])
        let slice = Input.Slice(collection)
        let offset0: Index<Int>.Offset = 0
        let offset2: Index<Int>.Offset = 2
        let offset4: Index<Int>.Offset = 4
        #expect(slice[offset: offset0] == 10)
        #expect(slice[offset: offset2] == 30)
        #expect(slice[offset: offset4] == 50)
    }

    @Test
    func `remaining returns self`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [1, 2, 3])
        var slice = Input.Slice(collection)
        _ = try slice.remove.first()
        let remaining = slice.remaining
        #expect(remaining.count == slice.count)
        #expect(remaining.first == slice.first)
    }

    @Test
    func `remove.first() throws when empty`() {
        let collection = TestCollection<Int>(storage: [])
        var slice = Input.Slice(collection)
        #expect(throws: Input.Remove.Error<Int>.empty) {
            try slice.remove.first()
        }
    }

    @Test
    func `try? remove.first() returns nil when empty`() {
        let collection = TestCollection<Int>(storage: [])
        var slice = Input.Slice(collection)
        let result: Int?
        do throws(Input.Remove.Error<Int>) {
            result = try slice.remove.first()
        } catch {
            result = nil
        }
        #expect(result == nil)
        #expect(slice.isEmpty)
    }

    @Test
    func `try? remove.first() consumes element`() {
        let collection = TestCollection(storage: [1, 2, 3])
        var slice = Input.Slice(collection)
        let result: Int?
        do throws(Input.Remove.Error<Int>) {
            result = try slice.remove.first()
        } catch {
            result = nil
        }
        #expect(result == 1)
        #expect(slice.first == 2)
        let expectedCount: Index<Int>.Count = 2
        #expect(slice.count == expectedCount)
    }
}

// MARK: - Edge Cases

extension Input.`Slice Test`.`Edge Case` {
    @Test
    func `single element slice`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [42])
        var slice = Input.Slice(collection)
        #expect(!slice.isEmpty)
        #expect(slice.first == 42)
        let cp = slice.checkpoint
        #expect(try slice.remove.first() == 42)
        #expect(slice.isEmpty)
        do throws(Input.Restore.Error) {
            try slice.restore.to(cp)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(slice.first == 42)
    }

    @Test
    func `restore to checkpoint at end`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [1, 2])
        var slice = Input.Slice(collection)
        _ = try slice.remove.first()
        _ = try slice.remove.first()
        let cpAtEnd = slice.checkpoint
        #expect(slice.isEmpty)
        do throws(Input.Restore.Error) {
            try slice.restore.to(cpAtEnd)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(slice.isEmpty)
    }

    @Test
    func `nested checkpoint restore`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var slice = Input.Slice(collection)
        let cp1 = slice.checkpoint
        _ = try slice.remove.first()
        let cp2 = slice.checkpoint
        _ = try slice.remove.first()
        _ = try slice.remove.first()
        #expect(slice.first == 4)
        do throws(Input.Restore.Error) {
            try slice.restore.to(cp2)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(slice.first == 2)
        do throws(Input.Restore.Error) {
            try slice.restore.to(cp1)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(slice.first == 1)
    }

    @Test
    func `remove.first(0) is no-op`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [1, 2, 3])
        var slice = Input.Slice(collection)
        let zero: Index<Int>.Count = 0
        try slice.remove.first(zero)
        let expectedCount: Index<Int>.Count = 3
        #expect(slice.count == expectedCount)
        #expect(slice.first == 1)
    }

    @Test
    func `offset access after partial consumption`() throws(Input.Remove.Error<Int>) {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var slice = Input.Slice(collection)
        let two: Index<Int>.Count = 2
        try slice.remove.first(two)
        let offset0: Index<Int>.Offset = 0
        let offset2: Index<Int>.Offset = 2
        #expect(slice[offset: offset0] == 3)
        #expect(slice[offset: offset2] == 5)
    }

    @Test
    func `remove.first(n) throws when n > count`() {
        let collection = TestCollection(storage: [1, 2, 3])
        var slice = Input.Slice(collection)
        let five: Index<Int>.Count = 5
        let three: Index<Int>.Count = 3
        #expect(throws: Input.Remove.Error<Int>.insufficientElements(requested: five, available: three)) {
            try slice.remove.first(five)
        }
    }
}

// MARK: - Integration Tests

extension Input.`Slice Test`.Integration {
    @Test
    func `byte parsing scenario`() throws(Input.Remove.Error<UInt8>) {
        let bytes = TestCollection(storage: [UInt8](arrayLiteral: 0x48, 0x65, 0x6C, 0x6C, 0x6F))
        var input = Input.Slice(bytes)

        let cp = input.checkpoint
        _ = try input.remove.first()
        _ = try input.remove.first()
        #expect(input.first == 0x6C)  // 'l'

        do throws(Input.Restore.Error) {
            try input.restore.to(cp)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(input.first == 0x48)  // 'H'
    }

    @Test
    func `access.element(at:) total accessor`() throws(Input.Access.Error<Int>) {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var input = Input.Slice(collection)
        let offset0: Index<Int>.Offset = 0
        let offset4: Index<Int>.Offset = 4
        // Move `try` out of `#expect()` macro expansion — embedded typed-throws
        // closures inside the macro hit a Swift 6.3 Windows + 6.4-dev SIL
        // verification failure ("throw operand type does not match error result
        // type of function"). See Input.Buffer Tests.swift for the same
        // workaround on the buffer-cursor side.
        let v0 = try input.access.element(at: offset0)
        let v4 = try input.access.element(at: offset4)
        #expect(v0 == 1)
        #expect(v4 == 5)
        let offset10: Index<Int>.Offset = 10
        var threw = false
        do throws(Input.Access.Error<Int>) {
            _ = try input.access.element(at: offset10)
        } catch {
            threw = true
        }
        #expect(threw)
    }
}
