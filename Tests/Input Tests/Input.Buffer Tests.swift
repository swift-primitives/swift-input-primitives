import Testing

@testable import Input

extension Input {
    @Suite
    enum `Buffer Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

extension Input.`Buffer Test`.Unit {
    @Test
    func `init from array`() {
        let buffer = Input.Buffer([1, 2, 3, 4, 5])
        let expectedCount: Int = 5
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 1)
        #expect(buffer.isEmpty == false)
    }

    @Test
    func `init from sequence`() {
        let buffer = Input.Buffer(sequence: 1...5)
        let expectedCount: Int = 5
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 1)
    }

    @Test
    func `init with repeating element`() {
        let count: Int = 3
        let buffer = Input.Buffer(repeating: 42, count: count)
        #expect(buffer.count == count)
        #expect(buffer.first == 42)
    }

    @Test
    func `isEmpty returns true for empty buffer`() {
        let buffer: Input.Buffer<ContiguousArray<Int>> = Input.Buffer([])
        #expect(buffer.isEmpty == true)
        let expectedCount: Int = 0
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == nil)
    }

    @Test
    func `removeFirst() consumes element`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3])
        let first = try buffer.removeFirst()
        #expect(first == 1)
        let expectedCount: Int = 2
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 2)
    }

    @Test
    func `removeFirst(n) advances by n elements`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let three: Int = 3
        try buffer.removeFirst(three)
        let expectedCount: Int = 2
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 4)
    }

    @Test
    func `consumed tracks consumption`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let expected0: Int = 0
        let expected1: Int = 1
        let expected3: Int = 3
        #expect(buffer.consumed == expected0)
        _ = try buffer.removeFirst()
        #expect(buffer.consumed == expected1)
        let two: Int = 2
        try buffer.removeFirst(two)
        #expect(buffer.consumed == expected3)
    }

    @Test
    func `checkpoint returns current position`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        _ = try buffer.removeFirst()
        let cp = buffer.checkpoint
        _ = try buffer.removeFirst()
        #expect(buffer.first == 3)
        do throws(Input.Restore.Error) {
            try buffer.restore(to: cp)
        } catch {
            Issue.record("restore failed: \(error)")
            return
        }
        #expect(buffer.first == 2)
    }

    @Test
    func `checkpoint and restore roundtrip`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp = buffer.checkpoint
        _ = try buffer.removeFirst()
        _ = try buffer.removeFirst()
        let expectedCount3: Int = 3
        #expect(buffer.count == expectedCount3)
        do throws(Input.Restore.Error) {
            try buffer.restore(to: cp)
        } catch {
            Issue.record("restore failed: \(error)")
            return
        }
        let expectedCount5: Int = 5
        #expect(buffer.count == expectedCount5)
        #expect(buffer.first == 1)
    }

    @Test
    func `subscript offset access`() {
        let buffer = Input.Buffer([10, 20, 30, 40, 50])
        let offset0: Int = 0
        let offset2: Int = 2
        let offset4: Int = 4
        #expect(buffer[offset: offset0] == 10)
        #expect(buffer[offset: offset2] == 30)
        #expect(buffer[offset: offset4] == 50)
    }

    @Test
    func `removeFirst() throws when empty`() {
        var buffer: Input.Buffer<ContiguousArray<Int>> = Input.Buffer([])
        #expect(throws: Input.Remove.Error<Int>.empty) {
            try buffer.removeFirst()
        }
    }

    @Test
    func `removeFirst() failure preserves an empty input`() {
        var buffer: Input.Buffer<ContiguousArray<Int>> = Input.Buffer([])
        let result: Int?
        do throws(Input.Remove.Error<Int>) {
            result = try buffer.removeFirst()
        } catch {
            result = nil
        }
        #expect(result == nil)
        #expect(buffer.isEmpty == true)
        let expectedCount: Int = 0
        #expect(buffer.count == expectedCount)
    }

    @Test
    func `removeFirst() consumes an available element`() {
        var buffer = Input.Buffer([1, 2, 3])
        let result: Int?
        do throws(Input.Remove.Error<Int>) {
            result = try buffer.removeFirst()
        } catch {
            result = nil
        }
        #expect(result == 1)
        #expect(buffer.first == 2)
        let expectedCount: Int = 2
        #expect(buffer.count == expectedCount)
    }
}

extension Input.`Buffer Test`.`Edge Case` {
    @Test
    func `single element buffer`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([42])
        #expect(buffer.isEmpty == false)
        #expect(buffer.first == 42)
        let cp = buffer.checkpoint
        #expect(try buffer.removeFirst() == 42)
        #expect(buffer.isEmpty == true)
        do throws(Input.Restore.Error) {
            try buffer.restore(to: cp)
        } catch {
            Issue.record("restore failed: \(error)")
            return
        }
        #expect(buffer.first == 42)
    }

    @Test
    func `restore to checkpoint at end`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2])
        _ = try buffer.removeFirst()
        _ = try buffer.removeFirst()
        let cpAtEnd = buffer.checkpoint
        #expect(buffer.isEmpty == true)
        do throws(Input.Restore.Error) {
            try buffer.restore(to: cpAtEnd)
        } catch {
            Issue.record("restore failed: \(error)")
            return
        }
        #expect(buffer.isEmpty == true)
    }

    @Test
    func `nested checkpoint restore`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp1 = buffer.checkpoint
        _ = try buffer.removeFirst()
        let cp2 = buffer.checkpoint
        _ = try buffer.removeFirst()
        _ = try buffer.removeFirst()
        #expect(buffer.first == 4)
        do throws(Input.Restore.Error) {
            try buffer.restore(to: cp2)
        } catch {
            Issue.record("restore failed: \(error)")
            return
        }
        #expect(buffer.first == 2)
        do throws(Input.Restore.Error) {
            try buffer.restore(to: cp1)
        } catch {
            Issue.record("restore failed: \(error)")
            return
        }
        #expect(buffer.first == 1)
    }

    @Test
    func `removeFirst(0) is no-op`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3])
        let zero: Int = 0
        try buffer.removeFirst(zero)
        let expectedCount: Int = 3
        #expect(buffer.count == expectedCount)
        #expect(buffer.first == 1)
    }

    @Test
    func `offset access after partial consumption`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let two: Int = 2
        try buffer.removeFirst(two)
        let offset0: Int = 0
        let offset2: Int = 2
        #expect(buffer[offset: offset0] == 3)
        #expect(buffer[offset: offset2] == 5)
    }

    @Test
    func `consumed preserved across restore`() throws(Input.Remove.Error<Int>) {
        var buffer = Input.Buffer([1, 2, 3, 4, 5])
        let cp = buffer.checkpoint
        let three: Int = 3
        try buffer.removeFirst(three)
        #expect(buffer.consumed == three)
        do throws(Input.Restore.Error) {
            try buffer.restore(to: cp)
        } catch {
            Issue.record("restore failed: \(error)")
            return
        }
        let zero: Int = 0
        #expect(buffer.consumed == zero)
    }

    @Test
    func `removeFirst(n) throws when n > count`() {
        var buffer = Input.Buffer([1, 2, 3])
        let five: Int = 5
        let three: Int = 3
        #expect(
            throws: Input.Remove.Error<Int>.insufficientElements(requested: five, available: three)
        ) {
            try buffer.removeFirst(five)
        }
    }

    @Test
    func `removeFirst(n) throws when n is negative`() {
        var buffer = Input.Buffer([1, 2, 3])
        #expect(
            throws: Input.Remove.Error<Int>.insufficientElements(requested: -1, available: 3)
        ) {
            try buffer.removeFirst(-1)
        }
        #expect(buffer.first == 1)
        #expect(buffer.count == 3)
    }

    @Test
    func `restore throws for invalid checkpoint`() {
        var buffer = Input.Buffer([1, 2, 3])
        let invalidCheckpoint: Int = 100
        #expect(throws: Input.Restore.Error.invalidCheckpoint) {
            try buffer.restore(to: invalidCheckpoint)
        }
    }
}

extension Input.`Buffer Test`.Integration {
    @Test
    func `byte parsing scenario`() throws(Input.Remove.Error<UInt8>) {
        let bytes: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
        var input = Input.Buffer(bytes)

        let cp = input.checkpoint
        _ = try input.removeFirst()
        _ = try input.removeFirst()
        #expect(input.first == 0x6C)

        do throws(Input.Restore.Error) {
            try input.restore(to: cp)
        } catch {
            Issue.record("restore failed: \(error)")
            return
        }
        #expect(input.first == 0x48)
    }

    @Test
    func `lookahead without consumption`() {
        let input = Input.Buffer([1, 2, 3, 4, 5])
        let offset0: Int = 0
        let offset4: Int = 4
        #expect(input[offset: offset0] == 1)
        #expect(input[offset: offset4] == 5)
        let expectedCount: Int = 5
        #expect(input.count == expectedCount)
    }

    @Test
    func `complete consumption`() throws(Input.Remove.Error<Int>) {
        var input = Input.Buffer([1, 2, 3])
        var consumed: [Int] = []
        while input.isEmpty == false {
            consumed.append(try input.removeFirst())
        }
        #expect(consumed == [1, 2, 3])
        #expect(input.isEmpty == true)
        let expected3: Int = 3
        #expect(input.consumed == expected3)
    }

    @Test
    func `element(at:) total accessor`() throws(Input.Access.Error<Int>) {
        let input = Input.Buffer([1, 2, 3, 4, 5])
        let offset0: Int = 0
        let offset4: Int = 4

        let v0 = try input.element(at: offset0)
        let v4 = try input.element(at: offset4)
        #expect(v0 == 1)
        #expect(v4 == 5)
        let offset10: Int = 10
        var threw = false
        do throws(Input.Access.Error<Int>) {
            _ = try input.element(at: offset10)
        } catch {
            threw = true
        }
        #expect(threw)
    }
}
