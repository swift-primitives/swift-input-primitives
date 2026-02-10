//
//  Input.Buffer Tests.swift
//  swift-input-primitives
//

import Testing

@testable import Input_Primitives
import Input_Primitives_Test_Support

// MARK: - Test Suite Structure

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
        let expectedCount: Index<Int>.Count = 5
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 1)
        #expect(buffer.isEmpty == false)
    }

    @Test("init from sequence")
    func initFromSequence() {
        let buffer = Input.Buffer(sequence: 1...5)
        let expectedCount: Index<Int>.Count = 5
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 1)
    }

    @Test("init with repeating element")
    func initWithRepeating() {
        let buffer = Input.Buffer(repeating: 42, count: 3)
        let expectedCount: Index<Int>.Count = 3
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 42)
    }

    @Test("isEmpty returns true for empty buffer")
    func isEmptyForEmptyBuffer() {
        let buffer: Input.Buffer<ContiguousArray<Int>> = Input.Buffer([])
        #expect(buffer.isEmpty == true)
        let expectedCount: Index<Int>.Count = 0
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == nil)
    }

    @Test("remove.first() consumes element")
    func removeFirstConsumesElement() throws {
        var buffer = Input.Buffer([1, 2, 3])
        let first = try buffer.remove.first()
        #expect(first == 1)
        let expectedCount: Index<Int>.Count = 2
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 2)
    }

    @Test("remove.first(n) advances by n elements")
    func removeFirstNAdvances() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let three: Index<Int>.Count = 3
        try buffer.remove.first(three)
        let expectedCount: Index<Int>.Count = 2
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 4)
    }

    @Test("consumedCount tracks consumption")
    func consumedCountTracksConsumption() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let expected0: Index<Int>.Count = 0
        let expected1: Index<Int>.Count = 1
        let expected3: Index<Int>.Count = 3
        #expect(buffer.consumedCount == expected0)
        _ = try buffer.remove.first()
        #expect(buffer.consumedCount == expected1)
        let two: Index<Int>.Count = 2
        try buffer.remove.first(two)
        #expect(buffer.consumedCount == expected3)
    }

    @Test("checkpoint returns current position")
    func checkpointReturnsPosition() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        _ = try buffer.remove.first()
        let cp = buffer.checkpoint
        _ = try buffer.remove.first()
        #expect(buffer.first == 3)
        try buffer.restore.to(cp)
        #expect(buffer.first == 2)
    }

    @Test("checkpoint and restore roundtrip")
    func checkpointRestoreRoundtrip() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp = buffer.checkpoint
        _ = try buffer.remove.first()
        _ = try buffer.remove.first()
        let expectedCount3: Index<Int>.Count = 3
        #expect(buffer.count == expectedCount3)
        try buffer.restore.to(cp)
        let expectedCount5: Index<Int>.Count = 5
        #expect(buffer.count == expectedCount5)
        #expect(buffer.first == 1)
    }

    @Test("subscript offset access")
    func subscriptOffsetAccess() {
        let buffer = Input.Buffer([10, 20, 30, 40, 50])
        let offset0: Index<Int>.Offset = 0
        let offset2: Index<Int>.Offset = 2
        let offset4: Index<Int>.Offset = 4
        #expect(buffer[offset: offset0] == 10)
        #expect(buffer[offset: offset2] == 30)
        #expect(buffer[offset: offset4] == 50)
    }

    @Test("remove.first() throws when empty")
    func removeFirstThrowsWhenEmpty() {
        var buffer: Input.Buffer<ContiguousArray<Int>> = Input.Buffer([])
        #expect(throws: Input.Remove.Error<Int>.empty) {
            try buffer.remove.first()
        }
    }

    @Test("try? remove.first() returns nil when empty")
    func tryRemoveFirstReturnsNilWhenEmpty() {
        var buffer: Input.Buffer<ContiguousArray<Int>> = Input.Buffer([])
        let result = try? buffer.remove.first()
        #expect(result == nil)
        #expect(buffer.isEmpty == true)
        let expectedCount: Index<Int>.Count = 0
        #expect(buffer.count == expectedCount)
    }

    @Test("try? remove.first() consumes element")
    func tryRemoveFirstConsumesElement() {
        var buffer = Input.Buffer([1, 2, 3])
        let result = try? buffer.remove.first()
        #expect(result == 1)
        #expect(buffer.first == 2)
        let expectedCount: Index<Int>.Count = 2
        #expect(buffer.count == expectedCount)
    }
}

// MARK: - Edge Cases

extension InputBufferTests.Test.EdgeCase {
    @Test("single element buffer")
    func singleElementBuffer() throws {
        var buffer = Input.Buffer([42])
        #expect(buffer.isEmpty == false)
        #expect(buffer.first == 42)
        let cp = buffer.checkpoint
        #expect(try buffer.remove.first() == 42)
        #expect(buffer.isEmpty == true)
        try buffer.restore.to(cp)
        #expect(buffer.first == 42)
    }

    @Test("restore to checkpoint at end")
    func restoreToCheckpointAtEnd() throws {
        var buffer = Input.Buffer([1, 2])
        _ = try buffer.remove.first()
        _ = try buffer.remove.first()
        let cpAtEnd = buffer.checkpoint
        #expect(buffer.isEmpty == true)
        try buffer.restore.to(cpAtEnd)
        #expect(buffer.isEmpty == true)
    }

    @Test("nested checkpoint restore")
    func nestedCheckpointRestore() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp1 = buffer.checkpoint
        _ = try buffer.remove.first()
        let cp2 = buffer.checkpoint
        _ = try buffer.remove.first()
        _ = try buffer.remove.first()
        #expect(buffer.first == 4)
        try buffer.restore.to(cp2)
        #expect(buffer.first == 2)
        try buffer.restore.to(cp1)
        #expect(buffer.first == 1)
    }

    @Test("remove.first(0) is no-op")
    func removeFirstZeroIsNoop() throws {
        var buffer = Input.Buffer([1, 2, 3])
        let zero: Index<Int>.Count = 0
        try buffer.remove.first(zero)
        let expectedCount: Index<Int>.Count = 3
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 1)
    }

    @Test("offset access after partial consumption")
    func offsetAccessAfterConsumption() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let two: Index<Int>.Count = 2
        try buffer.remove.first(two)
        let offset0: Index<Int>.Offset = 0
        let offset2: Index<Int>.Offset = 2
        #expect(buffer[offset: offset0] == 3)
        #expect(buffer[offset: offset2] == 5)
    }

    @Test("consumedCount preserved across restore")
    func consumedCountAfterRestore() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp = buffer.checkpoint
        let three: Index<Int>.Count = 3
        try buffer.remove.first(three)
        #expect(buffer.consumedCount == three)
        try buffer.restore.to(cp)
        let zero: Index<Int>.Count = 0
        #expect(buffer.consumedCount == zero)
    }

    @Test("remove.first(n) throws when n > count")
    func removeFirstNThrowsWhenInsufficient() {
        var buffer = Input.Buffer([1, 2, 3])
        let five: Index<Int>.Count = 5
        let three: Index<Int>.Count = 3
        #expect(throws: Input.Remove.Error<Int>.insufficientElements(requested: five, available: three)) {
            try buffer.remove.first(five)
        }
    }

    @Test("restore throws for invalid checkpoint")
    func restoreThrowsForInvalidCheckpoint() {
        var buffer = Input.Buffer([1, 2, 3])
        let invalidCheckpoint: Index<Int> = 100
        #expect(throws: Input.Restore.Error.invalidCheckpoint) {
            try buffer.restore.to(invalidCheckpoint)
        }
    }
}

// MARK: - Integration Tests

extension InputBufferTests.Test.Integration {
    @Test("byte parsing scenario")
    func byteParsingScenario() throws {
        let bytes: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F] // "Hello"
        var input = Input.Buffer(bytes)

        let cp = input.checkpoint
        _ = try input.remove.first()
        _ = try input.remove.first()
        #expect(input.first == 0x6C) // 'l'

        try input.restore.to(cp)
        #expect(input.first == 0x48) // 'H'
    }

    @Test("lookahead without consumption")
    func lookaheadWithoutConsumption() {
        let input = Input.Buffer([1, 2, 3, 4, 5])
        let offset0: Index<Int>.Offset = 0
        let offset4: Index<Int>.Offset = 4
        #expect(input[offset: offset0] == 1)
        #expect(input[offset: offset4] == 5)
        let expectedCount: Index<Int>.Count = 5
        #expect(input.count == expectedCount)
    }

    @Test("complete consumption")
    func completeConsumption() throws {
        var input = Input.Buffer([1, 2, 3])
        var consumed: [Int] = []
        while input.isEmpty == false {
            consumed.append(try input.remove.first())
        }
        #expect(consumed == [1, 2, 3])
        #expect(input.isEmpty == true)
        let expected3: Index<Int>.Count = 3
        #expect(input.consumedCount == expected3)
    }

    @Test("access.element(at:) total accessor")
    func elementAtTotalAccessor() throws {
        var input = Input.Buffer([1, 2, 3, 4, 5])
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
