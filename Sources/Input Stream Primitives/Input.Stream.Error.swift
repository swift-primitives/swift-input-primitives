extension Input.Stream {

    public enum Error: Swift.Error, Sendable, Equatable {

        case empty
    }
}

extension Input.Stream.Error: CustomStringConvertible {

    public var description: String {
        switch self {
        case .empty:
            return "input is empty"
        }
    }
}
