//
//  Input.Slice.Error.swift
//  swift-input-primitives
//
//  Error type for slice construction.
//

// MARK: - Hoisted Error Type (Module Level)
//
// Swift does not allow nested types inside generic types to be easily accessed.
// This error type is hoisted to module level and exposed via typealias to
// provide the expected Nest.Name API (Input.Slice.Error).
//
// This is a documented exception per [API-ERR-009] due to Swift language
// limitations with generic nested types.
//
// Use the typealias form in your code:
// - Input.Slice<Base>.Error

/// Hoisted implementation of ``Input/Slice/Error``.
///
/// - Note: Use ``Input/Slice/Error`` in your code, not this type directly.
public enum __InputSliceError: Swift.Error, Sendable, Equatable {
    /// Bounds are invalid.
    ///
    /// Thrown when `startIndex > endIndex`.
    ///
    /// - Parameters:
    ///   - startIndex: The provided start index (as offset from base start).
    ///   - endIndex: The provided end index (as offset from base start).
    case invalidBounds(startIndex: Int, endIndex: Int)
}

//// MARK: - Typealias (Nest.Name API)
//
//extension Input.Slice {
//    /// Errors for slice construction.
//    ///
//    /// Thrown when constructing a slice with invalid bounds.
//    ///
//    /// ## Cases
//    ///
//    /// - ``invalidBounds(startIndex:endIndex:)``: The start index exceeds the end index.
//    public typealias Error = __InputSliceError
//}

extension Input.Slice {
    /// Errors for slice construction.
    ///
    /// Thrown when constructing a slice with invalid bounds.
    ///
    /// ## Cases
    ///
    /// - ``invalidBounds(startIndex:endIndex:)``: The start index exceeds the end index.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Bounds are invalid.
        ///
        /// Thrown when `startIndex > endIndex`.
        ///
        /// - Parameters:
        ///   - startIndex: The provided start index (as offset from base start).
        ///   - endIndex: The provided end index (as offset from base start).
        case invalidBounds(startIndex: Base.Index, endIndex: Base.Index)
    }
}
