//
//  Input.Slice.Error.swift
//  swift-input-primitives
//
//  Error type for slice construction.
//

public import Collection_Primitives
internal import Index_Primitives

extension Input.Slice where Base: Collection.`Protocol` {
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

// MARK: - Validated Init

extension Input.Slice where Base: Collection.`Protocol`, Base.Index: Sendable {
    /// Creates a slice cursor with explicit bounds.
    ///
    /// - Parameters:
    ///   - base: The collection to wrap.
    ///   - startIndex: The starting index.
    ///   - endIndex: The ending index.
    /// - Throws: ``Error/invalidBounds(startIndex:endIndex:)`` if
    ///   `startIndex > endIndex`.
    @inlinable
    public init(
        base: Base,
        startIndex: Base.Index,
        endIndex: Base.Index
    ) throws(Input.Slice<Base>.Error) {
        guard startIndex <= endIndex else {
            throw .invalidBounds(
                startIndex: startIndex,
                endIndex: endIndex
            )
        }
        self.init(
            _base: base,
            start: Int(bitPattern: startIndex),
            end: Int(bitPattern: endIndex),
            position: 0
        )
    }
}
