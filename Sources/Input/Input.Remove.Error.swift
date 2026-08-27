public import Index

extension Input.Remove {

    public enum Error<Element: ~Copyable>: Swift.Error, Sendable, Equatable {

        case empty

        case insufficientElements(requested: Index<Element>.Count, available: Index<Element>.Count)
    }
}
