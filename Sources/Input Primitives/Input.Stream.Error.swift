//
//  Input.Stream.Error.swift
//  swift-input-primitives
//
//  Error type for streaming input operations.
//

extension Input.Stream {
    /// Errors for streaming input operations.
    ///
    /// Thrown by the `advance()` primitive when the input cannot satisfy the request.
    ///
    /// ## Cases
    ///
    /// - ``empty``: The input is empty.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input is empty.
        ///
        /// Thrown by `advance()` when no elements remain.
        case empty
    }
}

// MARK: - CustomStringConvertible

extension Input.Stream.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "input is empty"
        }
    }
}
