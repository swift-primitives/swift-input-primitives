# Experiments Index

| Directory | Purpose | Date | Toolchain | Status |
|-----------|---------|------|-----------|--------|
| noncopyable-streaming | Can Input.Stream.Protocol work with ~Copyable elements via `_read`? | 2026-01-23 | Swift 6.2.3 | CONFIRMED (PARTIALLY) |
| consuming-protocol-return | Can protocol methods return ~Copyable values via consuming semantics? | 2026-02-13 | Swift 6.2.3 | CONFIRMED |
| read-accessor-noncopyable-optional | Can `_read` yield through `Optional<~Copyable>`? | 2026-02-13 | Swift 6.2.3 | REFUTED |
| constraint-poisoning-module-split | Does `~Escapable` on result builder generic param fix constraint poisoning? | 2026-02-13 | Swift 6.2.3 | CONFIRMED |
