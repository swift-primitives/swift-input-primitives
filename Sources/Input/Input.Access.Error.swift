extension Input.Access {

    public enum Error<Element: ~Copyable>: Swift.Error, Sendable, Equatable {

        case outOfBounds(offset: Int, count: Int)
    }
}
