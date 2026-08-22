# GitHub Copilot instructions

Read the repository-root [AGENTS.md](../AGENTS.md) before proposing or
reviewing a change. It is the authoritative workflow and safety policy.

For timezone behavior, verify the current implementation, tests, and the
`timezone` dependency contract. Do not assume one universal DST gap or overlap
resolution. Public API, parsing, or documentation changes require matching
tests and the documentation routing in [doc/README.md](../doc/README.md).
