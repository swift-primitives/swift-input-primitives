import Input
import Input_Standard_Library_Integration
import Testing

@Suite struct `Optional Input Restorable Tests` {

    @Test
    func `optional input backtracks to its checkpoint`() {
        var response: Int? = nil
        let checkpoint = response.checkpoint
        response = 42
        response.seek(to: checkpoint)
        #expect(response == nil)
    }
}
