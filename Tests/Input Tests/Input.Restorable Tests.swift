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
    func `seek restores through the protocol primitive`() {
        var record = Record(count: 1, name: "a")
        let checkpoint = record.checkpoint
        record.count = 9
        record.seek(to: checkpoint)
        #expect(record == Record(count: 1, name: "a"))
    }
}
