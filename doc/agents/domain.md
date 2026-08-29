# Domain Docs

## Authority and scope

This is a single-context repository.

- `CONTEXT.md` is the version-controlled glossary for domain vocabulary.
- `doc/adr/` contains accepted architectural decisions whose rationale is
  expected to remain useful across releases.
- `doc/README.md` defines the owner and publication rules for authored
  documentation.
- The implementation and its tests are the source of truth for behavior.

Before changing a domain concept, read `CONTEXT.md`. Before changing an area
affected by an architectural decision, read the relevant ADRs in `doc/adr/`.
Use the glossary's canonical terms.

## ADR policy

Create `doc/adr/` lazily, when the first qualifying decision is accepted.
Name records sequentially: `0001-short-slug.md`, then increment from the
highest existing number.

An ADR is appropriate only when all are true:

1. The decision is accepted rather than still under evaluation.
2. It is materially hard to reverse.
3. A future contributor would find the choice surprising without its rationale.
4. The rationale comes from a real trade-off and relies on facts expected to
   remain reliable across releases.

Keep the record concise: state the context, the decision, and why. Add status,
alternatives, or consequences only when they materially help future readers.

ADRs do not contain task notes, release plans, temporary diagnostics, candidate
APIs, or decisions still under evaluation. They do not reserve future APIs or
override implemented behavior. Agents may draft an ADR only after a maintainer
explicitly approves recording that decision.
