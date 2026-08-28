import Testing

@testable import Input

extension Input {
    @Suite
    enum `Restorable Test` {
        @Suite struct Unit {}
    }
}

private struct Record: Input.Restorable, Equatable {

    typealias Checkpoint = Self

    var count: Int

    var name: String
}

extension Input.`Restorable Test`.Unit {

    @Test
    func `checkpoint captures the whole record value`() {
        let record = Record(count: 1, name: "a")
        #expect(record.checkpoint == record)
    }

    @Test
    func `seek restores a mutated record to its checkpoint`() {
        var record = Record(count: 1, name: "a")
        let checkpoint = record.checkpoint
        record.count = 2
        record.name = "b"
        record.seek(to: checkpoint)
        #expect(record == Record(count: 1, name: "a"))
    }

    @Test
    func `restore sugar seeks through the unchecked overload`() {
        var record = Record(count: 1, name: "a")
        let checkpoint = record.checkpoint
        record.count = 9
        record.restore.to(__unchecked: (), checkpoint)
        #expect(record == Record(count: 1, name: "a"))
    }

    @Test
    func `optional input backtracks to its checkpoint`() {
        var response: Int? = nil
        let checkpoint = response.checkpoint
        response = 42
        response.seek(to: checkpoint)
        #expect(response == nil)
    }
}
