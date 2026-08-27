public import Index

extension Input.Access {

    public enum Error<Element: ~Copyable>: Swift.Error, Sendable, Equatable {

        case outOfBounds(offset: Index<Element>.Offset, count: Index<Element>.Count)
    }
}
