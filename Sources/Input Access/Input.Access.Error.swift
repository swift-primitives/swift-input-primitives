public import Affine_Tagged
public import Index
public import Ordinal_Protocol
public import Tagged

extension Input.Access {

    public enum Error<Element: ~Copyable>: Swift.Error, Sendable, Equatable {

        case outOfBounds(
            offset: Index::Index<Element>.Offset,
            count: Index::Index<Element>.Count
        )
    }
}
