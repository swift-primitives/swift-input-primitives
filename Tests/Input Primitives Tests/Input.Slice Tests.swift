//
//  Input.Slice Tests.swift
//  swift-input-primitives
//

import Testing

@testable import Input_Primitives
public import Collection_Primitives

extension ArraySlice: Collection.`Protocol` {
    public var startIndex: Index {
        .zero
    }
    
    public var endIndex: Index {
        .max
    }
    
    public func index(after i: Index) -> Index {
        fatalError()
    }
}

// MARK: - Test Suite Structure

// Note: Input.Slice is generic, so we use a dedicated test enum per TEST-ORG-005
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
    @Test("init from array slice")
    func initFromArraySlice() {
        let array = [1, 2, 3, 4, 5]
        let slice = Input.Slice(array[...])
        #expect(slice.count == 5)
        #expect(slice.first == 1)
        #expect(!slice.isEmpty)
    }

    @Test("isEmpty returns true for empty slice")
    func isEmptyForEmptySlice() {
        let array: [Int] = []
        let slice = Input.Slice(array[...])
        #expect(slice.isEmpty)
        #expect(slice.count == 0)
        #expect(slice.first == nil)
    }

    @Test("remove.first() consumes element")
    func removeFirstConsumesElement() throws {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        let first = try slice.remove.first()
        #expect(first == 1)
        #expect(slice.count == 2)
        #expect(slice.first == 2)
    }

    @Test("remove.first(n) advances by n elements")
    func removeFirstNAdvances() throws {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        try slice.remove.first(3)
        #expect(slice.count == 2)
        #expect(slice.first == 4)
    }

    @Test("checkpoint returns current position")
    func checkpointReturnsPosition() throws {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        _ = try slice.remove.first()
        let cp = slice.checkpoint
        _ = try slice.remove.first()
        #expect(slice.first == 3)
        try slice.restore.to(cp)
        #expect(slice.first == 2)
    }

    @Test("checkpoint and restore roundtrip")
    func checkpointRestoreRoundtrip() throws {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        let cp = slice.checkpoint
        _ = try slice.remove.first()
        _ = try slice.remove.first()
        #expect(slice.count == 3)
        try slice.restore.to(cp)
        #expect(slice.count == 5)
        #expect(slice.first == 1)
    }

    @Test("subscript offset access")
    func subscriptOffsetAccess() {
        let array = [10, 20, 30, 40, 50]
        let slice = Input.Slice(array[...])
        #expect(slice[offset: 0] == 10)
        #expect(slice[offset: 2] == 30)
        #expect(slice[offset: 4] == 50)
    }

    @Test("access.starts(with:) prefix check")
    func startsWithPrefixCheck() {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        #expect(slice.access.starts(with: [1, 2, 3]) == true)
        #expect(slice.access.starts(with: [1, 2, 4]) == false)
        #expect(slice.access.starts(with: [1, 2, 3, 4, 5, 6]) == false)
    }

    @Test("access.starts(with:) single element")
    func startsWithSingleElement() {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        #expect(slice.access.starts(with: 1) == true)
        #expect(slice.access.starts(with: 2) == false)
    }

    @Test("remaining returns self")
    func remainingReturnsSelf() throws {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        _ = try slice.remove.first()
        let remaining = slice.remaining
        #expect(remaining.count == slice.count)
        #expect(remaining.first == slice.first)
    }

    @Test("remove.first() throws when empty")
    func removeFirstThrowsWhenEmpty() {
        let array: [Int] = []
        var slice = Input.Slice(array[...])
        #expect(throws: Input.Remove.Error.empty) {
            try slice.remove.first()
        }
    }

    @Test("try? remove.first() returns nil when empty")
    func tryRemoveFirstReturnsNilWhenEmpty() {
        let array: [Int] = []
        var slice = Input.Slice(array[...])
        let result = try? slice.remove.first()
        #expect(result == nil)
        #expect(slice.isEmpty)
    }

    @Test("try? remove.first() consumes element")
    func tryRemoveFirstConsumesElement() {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        let result = try? slice.remove.first()
        #expect(result == 1)
        #expect(slice.first == 2)
        #expect(slice.count == 2)
    }
}

// MARK: - Edge Cases

extension InputSliceTests.Test.EdgeCase {
    @Test("single element slice")
    func singleElementSlice() throws {
        let array = [42]
        var slice = Input.Slice(array[...])
        #expect(!slice.isEmpty)
        #expect(slice.first == 42)
        let cp = slice.checkpoint
        #expect(try slice.remove.first() == 42)
        #expect(slice.isEmpty)
        try slice.restore.to(cp)
        #expect(slice.first == 42)
    }

    @Test("restore to checkpoint at end")
    func restoreToCheckpointAtEnd() throws {
        let array = [1, 2]
        var slice = Input.Slice(array[...])
        _ = try slice.remove.first()
        _ = try slice.remove.first()
        let cpAtEnd = slice.checkpoint
        #expect(slice.isEmpty)
        try slice.restore.to(cpAtEnd)
        #expect(slice.isEmpty)
    }

    @Test("nested checkpoint restore")
    func nestedCheckpointRestore() throws {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
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

    @Test("remove.first(0) is no-op")
    func removeFirstZeroIsNoop() throws {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        try slice.remove.first(0)
        #expect(slice.count == 3)
        #expect(slice.first == 1)
    }

    @Test("access.starts(with:) empty prefix returns true")
    func startsWithEmptyPrefix() {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        #expect(slice.access.starts(with: []) == true)
    }

    @Test("offset access after partial consumption")
    func offsetAccessAfterConsumption() throws {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        try slice.remove.first(2)
        #expect(slice[offset: 0] == 3)
        #expect(slice[offset: 2] == 5)
    }

    @Test("remove.first(n) throws when n > count")
    func removeFirstNThrowsWhenInsufficient() {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        #expect(throws: Input.Remove.Error.insufficientElements(requested: 5, available: 3)) {
            try slice.remove.first(5)
        }
    }
}

// MARK: - Integration Tests

extension InputSliceTests.Test.Integration {
    @Test("interop with standard ArraySlice")
    func interopWithArraySlice() {
        let array = [1, 2, 3, 4, 5]
        let arraySlice = array[1..<4]
        let inputSlice = Input.Slice(arraySlice)
        #expect(inputSlice.count == 3)
        #expect(inputSlice.first == 2)
    }

    @Test("byte parsing scenario")
    func byteParsingScenario() throws {
        let bytes: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F] // "Hello"
        var input = Input.Slice(bytes[...])

        let cp = input.checkpoint
        #expect(input.access.starts(with: [0x48, 0x65]) == true) // "He"
        _ = try input.remove.first()
        _ = try input.remove.first()
        #expect(input.first == 0x6C) // 'l'

        try input.restore.to(cp)
        #expect(input.first == 0x48) // 'H'
    }

    @Test("access.element(at:) total accessor")
    func elementAtTotalAccessor() throws {
        let array = [1, 2, 3, 4, 5]
        var input = Input.Slice(array[...])
        #expect(try input.access.element(at: 0) == 1)
        #expect(try input.access.element(at: 4) == 5)
        #expect(throws: Input.Access.Error.self) {
            try input.access.element(at: 10)
        }
    }
}
