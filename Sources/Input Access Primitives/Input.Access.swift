//
//  Input.Access.swift
//  swift-input-primitives
//
//  Namespace for random access types and operations.
//

// MARK: - Namespace

extension Input {
    /// Namespace for random access types and operations.
    ///
    /// Also serves as the phantom type tag for ``Property``.``View`` discrimination.
    ///
    /// Contains:
    /// - ``Random``: Protocol for random access capability
    /// - ``Error``: Error type for access operations
    public enum Access {}
}
