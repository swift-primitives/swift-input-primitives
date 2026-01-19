//
//  Input.Access.swift
//  swift-input-primitives
//
//  Namespace for input access patterns.
//

extension Input {
    /// Namespace for input access patterns.
    ///
    /// Contains protocol refinements that provide different access semantics:
    /// - ``Random``: Random access within remaining input (offset subscript, prefix checks)
    public enum Access {}
}
