public import Input

extension Swift.Optional: Input.Restorable {

    public typealias Checkpoint = Optional<Wrapped>
}
