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
        #expect(buffer.isEmpty == false)
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
        #expect(buffer.isEmpty == true)
        #expect(buffer.count == 0)
        #expect(buffer.first == nil)
    }

    @Test("remove.first() consumes element")
    func removeFirstConsumesElement() throws {
        var buffer = Input.Buffer([1, 2, 3])
        let first = try buffer.remove.first()
        #expect(first == 1)
        #expect(buffer.count == 2)
        #expect(buffer.first == 2)
    }

    @Test("remove.first(n) advances by n elements")
    func removeFirstNAdvances() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        try buffer.remove.first(3)
        #expect(buffer.count == 2)
        #expect(buffer.first == 4)
    }

    @Test("consumedCount tracks consumption")
    func consumedCountTracksConsumption() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        #expect(buffer.consumedCount == 0)
        _ = try buffer.remove.first()
        #expect(buffer.consumedCount == 1)
        try buffer.remove.first(2)
        #expect(buffer.consumedCount == 3)
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
        #expect(buffer.count == 3)
        try buffer.restore.to(cp)
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

    @Test("access.starts(with:) prefix check")
    func startsWithPrefixCheck() {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        #expect(buffer.access.starts(with: [1, 2, 3]) == true)
        #expect(buffer.access.starts(with: [1, 2, 4]) == false)
        #expect(buffer.access.starts(with: [1, 2, 3, 4, 5, 6]) == false)
    }

    @Test("access.starts(with:) single element")
    func startsWithSingleElement() {
        var buffer = Input.Buffer([1, 2, 3])
        #expect(buffer.access.starts(with: 1) == true)
        #expect(buffer.access.starts(with: 2) == false)
    }

    // Note: remaining property requires Copyable conformance.
    // Input.Buffer is now ~Copyable, so this test is removed.

    @Test("remove.first() throws when empty")
    func removeFirstThrowsWhenEmpty() {
        var buffer = Input.Buffer<Int>([])
        #expect(throws: Input.Remove<Input.Buffer<Int>>.Error.empty) {
            try buffer.remove.first()
        }
    }

    @Test("try? remove.first() returns nil when empty")
    func tryRemoveFirstReturnsNilWhenEmpty() {
        var buffer = Input.Buffer<Int>([])
        let result = try? buffer.remove.first()
        #expect(result == nil)
        #expect(buffer.isEmpty == true)
        #expect(buffer.count == 0)
    }

    @Test("try? remove.first() consumes element")
    func tryRemoveFirstConsumesElement() {
        var buffer = Input.Buffer([1, 2, 3])
        let result = try? buffer.remove.first()
        #expect(result == 1)
        #expect(buffer.first == 2)
        #expect(buffer.count == 2)
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
        try buffer.remove.first(0)
        #expect(buffer.count == 3)
        #expect(buffer.first == 1)
    }

    @Test("access.starts(with:) empty prefix returns true")
    func startsWithEmptyPrefix() {
        var buffer = Input.Buffer([1, 2, 3])
        #expect(buffer.access.starts(with: []) == true)
    }

    @Test("offset access after partial consumption")
    func offsetAccessAfterConsumption() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        try buffer.remove.first(2)
        #expect(buffer[offset: 0] == 3)
        #expect(buffer[offset: 2] == 5)
    }

    @Test("consumedCount preserved across restore")
    func consumedCountAfterRestore() throws {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp = buffer.checkpoint
        try buffer.remove.first(3)
        #expect(buffer.consumedCount == 3)
        try buffer.restore.to(cp)
        #expect(buffer.consumedCount == 0)
    }

    @Test("remove.first(n) throws when n > count")
    func removeFirstNThrowsWhenInsufficient() {
        var buffer = Input.Buffer([1, 2, 3])
        #expect(throws: Input.Remove<Input.Buffer<Int>>.Error.insufficientElements(requested: 5, available: 3)) {
            try buffer.remove.first(5)
        }
    }

    @Test("restore throws for invalid checkpoint")
    func restoreThrowsForInvalidCheckpoint() {
        var buffer = Input.Buffer([1, 2, 3])
        // Index<Element> is non-negative by construction, so we can't test -1
        // Test out-of-bounds checkpoint (position 100 for 3-element buffer)
        let invalidCheckpoint = Input.Buffer<Int>.Checkpoint(__unchecked: 100)
        #expect(throws: Input.Restore<Input.Buffer<Int>>.Error.invalidCheckpoint) {
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
        #expect(input.access.starts(with: [0x48, 0x65]) == true) // "He"
        _ = try input.remove.first()
        _ = try input.remove.first()
        #expect(input.first == 0x6C) // 'l'

        try input.restore.to(cp)
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
    func completeConsumption() throws {
        var input = Input.Buffer([1, 2, 3])
        var consumed: [Int] = []
        while input.isEmpty == false {
            consumed.append(try input.remove.first())
        }
        #expect(consumed == [1, 2, 3])
        #expect(input.isEmpty == true)
        #expect(input.consumedCount == 3)
    }

    @Test("access.element(at:) total accessor")
    func elementAtTotalAccessor() throws {
        var input = Input.Buffer([1, 2, 3, 4, 5])
        #expect(try input.access.element(at: 0) == 1)
        #expect(try input.access.element(at: 4) == 5)
        #expect(throws: Input.Access<Input.Buffer<Int>>.Error.self) {
            try input.access.element(at: 10)
        }
    }
}
