//
//  Input.Slice Tests.swift
//  swift-input-primitives
//

import Testing

@testable import Input_Primitives

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

    @Test("removeFirst consumes element")
    func removeFirstConsumesElement() {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        let first = slice.removeFirst()
        #expect(first == 1)
        #expect(slice.count == 2)
        #expect(slice.first == 2)
    }

    @Test("removeFirst(n) advances by n elements")
    func removeFirstNAdvances() {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        slice.removeFirst(3)
        #expect(slice.count == 2)
        #expect(slice.first == 4)
    }

    @Test("checkpoint returns current position")
    func checkpointReturnsPosition() {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        _ = slice.removeFirst()
        let cp = slice.checkpoint
        _ = slice.removeFirst()
        #expect(slice.first == 3)
        slice.restore(to: cp)
        #expect(slice.first == 2)
    }

    @Test("checkpoint and restore roundtrip")
    func checkpointRestoreRoundtrip() {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        let cp = slice.checkpoint
        _ = slice.removeFirst()
        _ = slice.removeFirst()
        #expect(slice.count == 3)
        slice.restore(to: cp)
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

    @Test("starts(with:) prefix check")
    func startsWithPrefixCheck() {
        let array = [1, 2, 3, 4, 5]
        let slice = Input.Slice(array[...])
        #expect(slice.starts(with: [1, 2, 3]))
        #expect(!slice.starts(with: [1, 2, 4]))
        #expect(!slice.starts(with: [1, 2, 3, 4, 5, 6]))
    }

    @Test("starts(with:) single element")
    func startsWithSingleElement() {
        let array = [1, 2, 3]
        let slice = Input.Slice(array[...])
        #expect(slice.starts(with: 1))
        #expect(!slice.starts(with: 2))
    }

    @Test("remaining returns self")
    func remainingReturnsSelf() {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        _ = slice.removeFirst()
        let remaining = slice.remaining
        #expect(remaining.count == slice.count)
        #expect(remaining.first == slice.first)
    }

    @Test("popFirst returns nil when empty")
    func popFirstReturnsNilWhenEmpty() {
        let array: [Int] = []
        var slice = Input.Slice(array[...])
        #expect(slice.popFirst() == nil)
        #expect(slice.isEmpty)
    }

    @Test("popFirst consumes element")
    func popFirstConsumesElement() {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        #expect(slice.popFirst() == 1)
        #expect(slice.first == 2)
        #expect(slice.count == 2)
    }
}

// MARK: - Edge Cases

extension InputSliceTests.Test.EdgeCase {
    @Test("single element slice")
    func singleElementSlice() {
        let array = [42]
        var slice = Input.Slice(array[...])
        #expect(!slice.isEmpty)
        #expect(slice.first == 42)
        let cp = slice.checkpoint
        #expect(slice.removeFirst() == 42)
        #expect(slice.isEmpty)
        slice.restore(to: cp)
        #expect(slice.first == 42)
    }

    @Test("restore to checkpoint at end")
    func restoreToCheckpointAtEnd() {
        let array = [1, 2]
        var slice = Input.Slice(array[...])
        _ = slice.removeFirst()
        _ = slice.removeFirst()
        let cpAtEnd = slice.checkpoint
        #expect(slice.isEmpty)
        slice.restore(to: cpAtEnd)
        #expect(slice.isEmpty)
    }

    @Test("nested checkpoint restore")
    func nestedCheckpointRestore() {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        let cp1 = slice.checkpoint
        _ = slice.removeFirst()
        let cp2 = slice.checkpoint
        _ = slice.removeFirst()
        _ = slice.removeFirst()
        #expect(slice.first == 4)
        slice.restore(to: cp2)
        #expect(slice.first == 2)
        slice.restore(to: cp1)
        #expect(slice.first == 1)
    }

    @Test("removeFirst(0) is no-op")
    func removeFirstZeroIsNoop() {
        let array = [1, 2, 3]
        var slice = Input.Slice(array[...])
        slice.removeFirst(0)
        #expect(slice.count == 3)
        #expect(slice.first == 1)
    }

    @Test("starts(with:) empty prefix returns true")
    func startsWithEmptyPrefix() {
        let array = [1, 2, 3]
        let slice = Input.Slice(array[...])
        #expect(slice.starts(with: [] as [Int]))
    }

    @Test("offset access after partial consumption")
    func offsetAccessAfterConsumption() {
        let array = [1, 2, 3, 4, 5]
        var slice = Input.Slice(array[...])
        slice.removeFirst(2)
        #expect(slice[offset: 0] == 3)
        #expect(slice[offset: 2] == 5)
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
    func byteParsingScenario() {
        let bytes: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F] // "Hello"
        var input = Input.Slice(bytes[...])

        let cp = input.checkpoint
        #expect(input.starts(with: [0x48, 0x65])) // "He"
        _ = input.removeFirst()
        _ = input.removeFirst()
        #expect(input.first == 0x6C) // 'l'

        input.restore(to: cp)
        #expect(input.first == 0x48) // 'H'
    }
}
