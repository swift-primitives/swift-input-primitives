extension Input.Remove {

    public enum Error<Element: ~Copyable>: Swift.Error, Sendable, Equatable {

        case empty

        case insufficientElements(requested: Int, available: Int)
    }
}
