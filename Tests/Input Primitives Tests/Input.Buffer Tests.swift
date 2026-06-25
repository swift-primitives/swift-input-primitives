//
//  Input.Buffer Tests.swift
//  swift-input-primitives
//

import Byte_Primitives
import Input_Primitives_Test_Support
import Testing

@testable import Input_Primitives

// MARK: - Test Suite Structure

extension Input {
    @Suite
    enum `Buffer Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension Input.`Buffer Test`.Unit {
    @Test
    func `init from array`() {
        let buffer = Input.Buffer([1, 2, 3, 4, 5])
        let expectedCount: Index<Int>.Count = 5
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 1)
        #expect(buffer.isEmpty == false)
    }

    @Test
    func `init from sequence`() {
        let buffer = Input.Buffer(sequence: 1...5)
        let expectedCount: Index<Int>.Count = 5
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 1)
    }

    @Test
    func `init with repeating element`() {
        let count: Index<Int>.Count = 3
        let buffer = Input.Buffer(repeating: 42, count: count)
        #expect(buffer.count == count)
        #expect(buffer.first == 42)
    }

    @Test
    func `isEmpty returns true for empty buffer`() {
        let buffer: Input.Buffer<ContiguousArray<Int>> = Input.Buffer([])
        #expect(buffer.isEmpty == true)
        let expectedCount: Index<Int>.Count = 0
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == nil)
    }

    @Test
    func `remove.first() consumes element`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3])
        let first = try buffer.remove.first()
        #expect(first == 1)
        let expectedCount: Index<Int>.Count = 2
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 2)
    }

    @Test
    func `remove.first(n) advances by n elements`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let three: Index<Int>.Count = 3
        try buffer.remove.first(three)
        let expectedCount: Index<Int>.Count = 2
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 4)
    }

    @Test
    func `consumed tracks consumption`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let expected0: Index<Int>.Count = 0
        let expected1: Index<Int>.Count = 1
        let expected3: Index<Int>.Count = 3
        #expect(buffer.consumed == expected0)
        _ = try buffer.remove.first()
        #expect(buffer.consumed == expected1)
        let two: Index<Int>.Count = 2
        try buffer.remove.first(two)
        #expect(buffer.consumed == expected3)
    }

    @Test
    func `checkpoint returns current position`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        _ = try buffer.remove.first()
        let cp = buffer.checkpoint
        _ = try buffer.remove.first()
        #expect(buffer.first == 3)
        do throws(Input.Restore.Error) {
            try buffer.restore.to(cp)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(buffer.first == 2)
    }

    @Test
    func `checkpoint and restore roundtrip`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp = buffer.checkpoint
        _ = try buffer.remove.first()
        _ = try buffer.remove.first()
        let expectedCount3: Index<Int>.Count = 3
        #expect(buffer.count == expectedCount3)
        do throws(Input.Restore.Error) {
            try buffer.restore.to(cp)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        let expectedCount5: Index<Int>.Count = 5
        #expect(buffer.count == expectedCount5)
        #expect(buffer.first == 1)
    }

    @Test
    func `subscript offset access`() {
        let buffer = Input.Buffer([10, 20, 30, 40, 50])
        let offset0: Index<Int>.Offset = 0
        let offset2: Index<Int>.Offset = 2
        let offset4: Index<Int>.Offset = 4
        #expect(buffer[offset: offset0] == 10)
        #expect(buffer[offset: offset2] == 30)
        #expect(buffer[offset: offset4] == 50)
    }

    @Test
    func `remove.first() throws when empty`() {
        var buffer: Input.Buffer<ContiguousArray<Int>> = Input.Buffer([])
        #expect(throws: Input.Remove.Error<Int>.empty) {
            try buffer.remove.first()
        }
    }

    @Test
    func `try? remove.first() returns nil when empty`() {
        var buffer: Input.Buffer<ContiguousArray<Int>> = Input.Buffer([])
        let result: Int?
        do throws(Input.Remove.Error<Int>) {
            result = try buffer.remove.first()
        } catch {
            result = nil
        }
        #expect(result == nil)
        #expect(buffer.isEmpty == true)
        let expectedCount: Index<Int>.Count = 0
        #expect(buffer.count == expectedCount)
    }

    @Test
    func `try? remove.first() consumes element`() {
        var buffer = Input.Buffer([1, 2, 3])
        let result: Int?
        do throws(Input.Remove.Error<Int>) {
            result = try buffer.remove.first()
        } catch {
            result = nil
        }
        #expect(result == 1)
        #expect(buffer.first == 2)
        let expectedCount: Index<Int>.Count = 2
        #expect(buffer.count == expectedCount)
    }
}

// MARK: - Edge Cases

extension Input.`Buffer Test`.`Edge Case` {
    @Test
    func `single element buffer`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([42])
        #expect(buffer.isEmpty == false)
        #expect(buffer.first == 42)
        let cp = buffer.checkpoint
        #expect(try buffer.remove.first() == 42)
        #expect(buffer.isEmpty == true)
        do throws(Input.Restore.Error) {
            try buffer.restore.to(cp)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(buffer.first == 42)
    }

    @Test
    func `restore to checkpoint at end`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2])
        _ = try buffer.remove.first()
        _ = try buffer.remove.first()
        let cpAtEnd = buffer.checkpoint
        #expect(buffer.isEmpty == true)
        do throws(Input.Restore.Error) {
            try buffer.restore.to(cpAtEnd)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(buffer.isEmpty == true)
    }

    @Test
    func `nested checkpoint restore`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp1 = buffer.checkpoint
        _ = try buffer.remove.first()
        let cp2 = buffer.checkpoint
        _ = try buffer.remove.first()
        _ = try buffer.remove.first()
        #expect(buffer.first == 4)
        do throws(Input.Restore.Error) {
            try buffer.restore.to(cp2)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(buffer.first == 2)
        do throws(Input.Restore.Error) {
            try buffer.restore.to(cp1)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        #expect(buffer.first == 1)
    }

    @Test
    func `remove.first(0) is no-op`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3])
        let zero: Index<Int>.Count = 0
        try buffer.remove.first(zero)
        let expectedCount: Index<Int>.Count = 3
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 1)
    }

    @Test
    func `offset access after partial consumption`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let two: Index<Int>.Count = 2
        try buffer.remove.first(two)
        let offset0: Index<Int>.Offset = 0
        let offset2: Index<Int>.Offset = 2
        #expect(buffer[offset: offset0] == 3)
        #expect(buffer[offset: offset2] == 5)
    }

    @Test
    func `consumed preserved across restore`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp = buffer.checkpoint
        let three: Index<Int>.Count = 3
        try buffer.remove.first(three)
        #expect(buffer.consumed == three)
        do throws(Input.Restore.Error) {
            try buffer.restore.to(cp)
        } catch {
            Issue.record("restore.to failed: \(error)")
            return
        }
        let zero: Index<Int>.Count = 0
        #expect(buffer.consumed == zero)
    }

    @Test
    func `remove.first(n) throws when n > count`() {
        var buffer = Input.Buffer([1, 2, 3])
        let five: Index<Int>.Count = 5
        let three: Index<Int>.Count = 3
        #expect(throws: Input.Remove.Error<Int>.insufficientElements(requested: five, available: three)) {
            try buffer.remove.first(five)
        }
    }

    @Test
    func `restore throws for invalid checkpoint`() {
        var buffer = Input.Buffer([1, 2, 3])
        let invalidCheckpoint: Index<Int> = 100
        #expect(throws: Input.Restore.Error.invalidCheckpoint) {
            try buffer.restore.to(invalidCheckpoint)
        }
    }
}

// MARK: - Integration Tests

extension Input.`Buffer Test`.Integration {
    @Test
    func `byte parsing scenario`() throws(Input.Remove.Error<Byte>) {
        let bytes: [Byte] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]  // "Hello"
        var input = Input.Buffer(bytes)

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
    func `lookahead without consumption`() {
        let input = Input.Buffer([1, 2, 3, 4, 5])
        let offset0: Index<Int>.Offset = 0
        let offset4: Index<Int>.Offset = 4
        #expect(input[offset: offset0] == 1)
        #expect(input[offset: offset4] == 5)
        let expectedCount: Index<Int>.Count = 5
        #expect(input.count == expectedCount)
    }

    @Test
    func `complete consumption`() throws(Input.Remove.Error<Int>) {
        var input = Input.Buffer([1, 2, 3])
        var consumed: [Int] = []
        while input.isEmpty == false {
            consumed.append(try input.remove.first())
        }
        #expect(consumed == [1, 2, 3])
        #expect(input.isEmpty == true)
        let expected3: Index<Int>.Count = 3
        #expect(input.consumed == expected3)
    }

    @Test
    func `access.element(at:) total accessor`() throws(Input.Access.Error<Int>) {
        var input = Input.Buffer([1, 2, 3, 4, 5])
        let offset0: Index<Int>.Offset = 0
        let offset4: Index<Int>.Offset = 4
        // Move `try` out of `#expect()` macro expansion — embedded typed-throws
        // closures inside the macro hit a Swift 6.3 Windows + 6.4-dev SIL
        // verification failure ("throw operand type does not match error result
        // type of function"). The bug is in macro+typed-throws+Property.Inout
        // generic interaction; the workaround is to bind the try-result locally
        // and assert on the bare value.
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
