//
//  Input.Slice Tests.swift
//  swift-input-primitives
//

import Testing

@testable import Input_Primitives
import Input_Primitives_Test_Support

/// Minimal Collection.Protocol conformer for testing Input.Slice.
struct TestCollection<Element: Sendable>: Collection.`Protocol`, Sendable {
    var storage: [Element]

    struct Iterator: Sequence.Iterator.`Protocol`, IteratorProtocol {
        var offset: Int
        let storage: [Element]
        var _element: Element? = nil

        @_lifetime(&self)
        mutating func nextSpan(maximumCount: Cardinal) -> Span<Element> {
            let ptr = unsafe withUnsafeMutablePointer(to: &_element) { p in
                unsafe UnsafePointer<Element>(
                    unsafe UnsafeRawPointer(p).assumingMemoryBound(to: Element.self)
                )
            }
            guard maximumCount > .zero else {
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

    var startIndex: Index_Primitives.Index<Element> { .zero }

    var endIndex: Index_Primitives.Index<Element> {
        Index_Primitives.Index<Element>.Count(Cardinal(UInt(storage.count))).map(Ordinal.init)
    }

    subscript(position: Index_Primitives.Index<Element>) -> Element {
        storage[Int(bitPattern: position)]
    }

    func index(after i: Index_Primitives.Index<Element>) -> Index_Primitives.Index<Element> {
        try! i.successor.exact()
    }

    func makeIterator() -> Iterator {
        Iterator(offset: 0, storage: storage)
    }
}

// MARK: - Test Suite Structure

enum InputSliceTests {
    @Suite
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension InputSliceTests.Test.Unit {
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
    func `remove.first() consumes element`() throws {
        let collection = TestCollection(storage: [1, 2, 3])
        var slice = Input.Slice(collection)
        let first = try slice.remove.first()
        #expect(first == 1)
        let expectedCount: Index<Int>.Count = 2
        #expect(slice.count == expectedCount)
        #expect(slice.first == 2)
    }

    @Test
    func `remove.first(n) advances by n elements`() throws {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var slice = Input.Slice(collection)
        let three: Index<Int>.Count = 3
        try slice.remove.first(three)
        let expectedCount: Index<Int>.Count = 2
        #expect(slice.count == expectedCount)
        #expect(slice.first == 4)
    }

    @Test
    func `checkpoint returns current position`() throws {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var slice = Input.Slice(collection)
        _ = try slice.remove.first()
        let cp = slice.checkpoint
        _ = try slice.remove.first()
        #expect(slice.first == 3)
        try slice.restore.to(cp)
        #expect(slice.first == 2)
    }

    @Test
    func `checkpoint and restore roundtrip`() throws {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var slice = Input.Slice(collection)
        let cp = slice.checkpoint
        _ = try slice.remove.first()
        _ = try slice.remove.first()
        let expectedCount3: Index<Int>.Count = 3
        #expect(slice.count == expectedCount3)
        try slice.restore.to(cp)
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
    func `remaining returns self`() throws {
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
        let result = try? slice.remove.first()
        #expect(result == nil)
        #expect(slice.isEmpty)
    }

    @Test
    func `try? remove.first() consumes element`() {
        let collection = TestCollection(storage: [1, 2, 3])
        var slice = Input.Slice(collection)
        let result = try? slice.remove.first()
        #expect(result == 1)
        #expect(slice.first == 2)
        let expectedCount: Index<Int>.Count = 2
        #expect(slice.count == expectedCount)
    }
}

// MARK: - Edge Cases

extension InputSliceTests.Test.EdgeCase {
    @Test
    func `single element slice`() throws {
        let collection = TestCollection(storage: [42])
        var slice = Input.Slice(collection)
        #expect(!slice.isEmpty)
        #expect(slice.first == 42)
        let cp = slice.checkpoint
        #expect(try slice.remove.first() == 42)
        #expect(slice.isEmpty)
        try slice.restore.to(cp)
        #expect(slice.first == 42)
    }

    @Test
    func `restore to checkpoint at end`() throws {
        let collection = TestCollection(storage: [1, 2])
        var slice = Input.Slice(collection)
        _ = try slice.remove.first()
        _ = try slice.remove.first()
        let cpAtEnd = slice.checkpoint
        #expect(slice.isEmpty)
        try slice.restore.to(cpAtEnd)
        #expect(slice.isEmpty)
    }

    @Test
    func `nested checkpoint restore`() throws {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var slice = Input.Slice(collection)
        let cp1 = slice.checkpoint
        _ = try slice.remove.first()
        let cp2 = slice.checkpoint
        _ = try slice.remove.first()
        _ = try slice.remove.first()
        #expect(slice.first == 4)
        try slice.restore.to(cp2)
        #expect(slice.first == 2)
        try slice.restore.to(cp1)
        #expect(slice.first == 1)
    }

    @Test
    func `remove.first(0) is no-op`() throws {
        let collection = TestCollection(storage: [1, 2, 3])
        var slice = Input.Slice(collection)
        let zero: Index<Int>.Count = 0
        try slice.remove.first(zero)
        let expectedCount: Index<Int>.Count = 3
        #expect(slice.count == expectedCount)
        #expect(slice.first == 1)
    }

    @Test
    func `offset access after partial consumption`() throws {
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

extension InputSliceTests.Test.Integration {
    @Test
    func `byte parsing scenario`() throws {
        let bytes = TestCollection(storage: [UInt8](arrayLiteral: 0x48, 0x65, 0x6C, 0x6C, 0x6F))
        var input = Input.Slice(bytes)

        let cp = input.checkpoint
        _ = try input.remove.first()
        _ = try input.remove.first()
        #expect(input.first == 0x6C) // 'l'

        try input.restore.to(cp)
        #expect(input.first == 0x48) // 'H'
    }

    @Test
    func `access.element(at:) total accessor`() throws {
        let collection = TestCollection(storage: [1, 2, 3, 4, 5])
        var input = Input.Slice(collection)
        let offset0: Index<Int>.Offset = 0
        let offset4: Index<Int>.Offset = 4
        #expect(try input.access.element(at: offset0) == 1)
        #expect(try input.access.element(at: offset4) == 5)
        let offset10: Index<Int>.Offset = 10
        #expect(throws: (any Error).self) {
            try input.access.element(at: offset10)
        }
    }
}
