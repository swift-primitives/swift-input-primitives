//
//  Input.Buffer Tests.swift
//  swift-input-primitives
//

import Testing

@testable import Input_Primitives

// MARK: - Test Suite Structure

// Note: Input.Buffer is generic, so we use a dedicated test enum per TEST-ORG-005
enum InputBufferTests {
    @Suite
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension InputBufferTests.Test.Unit {
    @Test("init from array")
    func initFromArray() {
        let buffer = Input.Buffer([1, 2, 3, 4, 5])
        #expect(buffer.count == 5)
        #expect(buffer.first == 1)
        #expect(!buffer.isEmpty)
    }

    @Test("init from sequence")
    func initFromSequence() {
        let buffer = Input.Buffer(1...5)
        #expect(buffer.count == 5)
        #expect(buffer.first == 1)
    }

    @Test("init with repeating element")
    func initWithRepeating() {
        let buffer = Input.Buffer(repeating: 42, count: 3)
        #expect(buffer.count == 3)
        #expect(buffer.first == 42)
    }

    @Test("isEmpty returns true for empty buffer")
    func isEmptyForEmptyBuffer() {
        let buffer = Input.Buffer<Int>([])
        #expect(buffer.isEmpty)
        #expect(buffer.count == 0)
        #expect(buffer.first == nil)
    }

    @Test("removeFirst consumes element")
    func removeFirstConsumesElement() {
        var buffer = Input.Buffer([1, 2, 3])
        let first = buffer.removeFirst()
        #expect(first == 1)
        #expect(buffer.count == 2)
        #expect(buffer.first == 2)
    }

    @Test("removeFirst(n) advances by n elements")
    func removeFirstNAdvances() {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        buffer.removeFirst(3)
        #expect(buffer.count == 2)
        #expect(buffer.first == 4)
    }

    @Test("consumedCount tracks consumption")
    func consumedCountTracksConsumption() {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        #expect(buffer.consumedCount == 0)
        _ = buffer.removeFirst()
        #expect(buffer.consumedCount == 1)
        buffer.removeFirst(2)
        #expect(buffer.consumedCount == 3)
    }

    @Test("checkpoint returns current position")
    func checkpointReturnsPosition() {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        _ = buffer.removeFirst()
        let cp = buffer.checkpoint
        _ = buffer.removeFirst()
        #expect(buffer.first == 3)
        buffer.restore(to: cp)
        #expect(buffer.first == 2)
    }

    @Test("checkpoint and restore roundtrip")
    func checkpointRestoreRoundtrip() {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp = buffer.checkpoint
        _ = buffer.removeFirst()
        _ = buffer.removeFirst()
        #expect(buffer.count == 3)
        buffer.restore(to: cp)
        #expect(buffer.count == 5)
        #expect(buffer.first == 1)
    }

    @Test("subscript offset access")
    func subscriptOffsetAccess() {
        let buffer = Input.Buffer([10, 20, 30, 40, 50])
        #expect(buffer[offset: 0] == 10)
        #expect(buffer[offset: 2] == 30)
        #expect(buffer[offset: 4] == 50)
    }

    @Test("starts(with:) prefix check")
    func startsWithPrefixCheck() {
        let buffer = Input.Buffer([1, 2, 3, 4, 5])
        #expect(buffer.starts(with: [1, 2, 3]))
        #expect(!buffer.starts(with: [1, 2, 4]))
        #expect(!buffer.starts(with: [1, 2, 3, 4, 5, 6]))
    }

    @Test("starts(with:) single element")
    func startsWithSingleElement() {
        let buffer = Input.Buffer([1, 2, 3])
        #expect(buffer.starts(with: 1))
        #expect(!buffer.starts(with: 2))
    }

    @Test("remaining returns self")
    func remainingReturnsSelf() {
        var buffer = Input.Buffer([1, 2, 3])
        _ = buffer.removeFirst()
        let remaining = buffer.remaining
        #expect(remaining.count == buffer.count)
        #expect(remaining.first == buffer.first)
    }

    @Test("popFirst returns nil when empty")
    func popFirstReturnsNilWhenEmpty() {
        var buffer = Input.Buffer<Int>([])
        #expect(buffer.popFirst() == nil)
        #expect(buffer.isEmpty)
        #expect(buffer.count == 0)
    }

    @Test("popFirst consumes element")
    func popFirstConsumesElement() {
        var buffer = Input.Buffer([1, 2, 3])
        #expect(buffer.popFirst() == 1)
        #expect(buffer.first == 2)
        #expect(buffer.count == 2)
    }
}

// MARK: - Edge Cases

extension InputBufferTests.Test.EdgeCase {
    @Test("single element buffer")
    func singleElementBuffer() {
        var buffer = Input.Buffer([42])
        #expect(!buffer.isEmpty)
        #expect(buffer.first == 42)
        let cp = buffer.checkpoint
        #expect(buffer.removeFirst() == 42)
        #expect(buffer.isEmpty)
        buffer.restore(to: cp)
        #expect(buffer.first == 42)
    }

    @Test("restore to checkpoint at end")
    func restoreToCheckpointAtEnd() {
        var buffer = Input.Buffer([1, 2])
        _ = buffer.removeFirst()
        _ = buffer.removeFirst()
        let cpAtEnd = buffer.checkpoint
        #expect(buffer.isEmpty)
        buffer.restore(to: cpAtEnd)
        #expect(buffer.isEmpty)
    }

    @Test("nested checkpoint restore")
    func nestedCheckpointRestore() {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp1 = buffer.checkpoint
        _ = buffer.removeFirst()
        let cp2 = buffer.checkpoint
        _ = buffer.removeFirst()
        _ = buffer.removeFirst()
        #expect(buffer.first == 4)
        buffer.restore(to: cp2)
        #expect(buffer.first == 2)
        buffer.restore(to: cp1)
        #expect(buffer.first == 1)
    }

    @Test("removeFirst(0) is no-op")
    func removeFirstZeroIsNoop() {
        var buffer = Input.Buffer([1, 2, 3])
        buffer.removeFirst(0)
        #expect(buffer.count == 3)
        #expect(buffer.first == 1)
    }

    @Test("starts(with:) empty prefix returns true")
    func startsWithEmptyPrefix() {
        let buffer = Input.Buffer([1, 2, 3])
        #expect(buffer.starts(with: [] as [Int]))
    }

    @Test("offset access after partial consumption")
    func offsetAccessAfterConsumption() {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        buffer.removeFirst(2)
        #expect(buffer[offset: 0] == 3)
        #expect(buffer[offset: 2] == 5)
    }

    @Test("consumedCount preserved across restore")
    func consumedCountAfterRestore() {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp = buffer.checkpoint
        buffer.removeFirst(3)
        #expect(buffer.consumedCount == 3)
        buffer.restore(to: cp)
        #expect(buffer.consumedCount == 0)
    }
}

// MARK: - Integration Tests

extension InputBufferTests.Test.Integration {
    @Test("byte parsing scenario")
    func byteParsingScenario() {
        let bytes: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F] // "Hello"
        var input = Input.Buffer(bytes)

        let cp = input.checkpoint
        #expect(input.starts(with: [0x48, 0x65])) // "He"
        _ = input.removeFirst()
        _ = input.removeFirst()
        #expect(input.first == 0x6C) // 'l'

        input.restore(to: cp)
        #expect(input.first == 0x48) // 'H'
    }

    @Test("lookahead without consumption")
    func lookaheadWithoutConsumption() {
        let input = Input.Buffer([1, 2, 3, 4, 5])

        // Lookahead via subscript doesn't consume
        #expect(input[offset: 0] == 1)
        #expect(input[offset: 4] == 5)
        #expect(input.count == 5) // Still 5 elements
    }

    @Test("complete consumption")
    func completeConsumption() {
        var input = Input.Buffer([1, 2, 3])
        var consumed: [Int] = []
        while !input.isEmpty {
            consumed.append(input.removeFirst())
        }
        #expect(consumed == [1, 2, 3])
        #expect(input.isEmpty)
        #expect(input.consumedCount == 3)
    }
}
