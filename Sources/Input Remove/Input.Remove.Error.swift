public import Index
public import Ordinal_Protocol
public import Tagged

extension Input.Remove {

    public enum Error<Element: ~Copyable>: Swift.Error, Sendable, Equatable {

        case empty

        case insufficientElements(
            requested: Index::Index<Element>.Count,
            available: Index::Index<Element>.Count
        )
    }
}
