//
//  Input.Access.Error.swift
//  swift-input-primitives
//
//  Error type for element access operations.
//

extension Input.Access {
    /// Errors for element access operations.
    ///
    /// Thrown by random access operations when the offset is out of bounds.
    ///
    /// ## Cases
    ///
    /// - ``outOfBounds(offset:count:)``: The offset is invalid.
    public enum Error<Element: ~Copyable>: Swift.Error, Sendable, Equatable {
        /// Offset is out of bounds.
        ///
        /// Thrown by `element(at:)` when the offset is negative
        /// or exceeds the remaining element count.
        ///
        /// - Parameters:
        ///   - offset: The requested offset.
        ///   - count: The number of elements available.
        case outOfBounds(offset: Index<Element>.Offset, count: Index<Element>.Count)
    }
}
