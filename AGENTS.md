# AGENTS.md

Root rules only. Read this file before changing the repository; add a scoped
`AGENTS.md` only when a subtree genuinely needs stricter rules.

## Start

- Inspect `git status --short` first. Preserve untracked and unrelated changes.
- Read [doc/README.md](doc/README.md) before documentation work and
  [CONTEXT.md](CONTEXT.md) before changing time semantics or terminology.
- Verify public behavior in source, tests, and dependency documentation. Do not
  infer timezone, DST, SDK, or parser behavior from a comment alone.

## Roles and authority

- **Maintainers** accept public API contracts, release notes, tags, and
  publication.
- **Contributors** propose focused code, tests, and authored documentation.
- **Agents** work as contributors: they may inspect, edit, and verify the
  requested scope, but never commit, push, tag, publish, or discard work unless
  explicitly authorized.

All repository guidance is public and must contain no credentials, private
operational details, or claims that cannot be verified from the repository.

## Contracts

- `EasyDateTime` is an additive `DateTime` enhancement. Preserve public
  behavior in v0.x unless a change is explicitly declared breaking.
- Keep instant-preserving conversion distinct from local-field relocation.
- Treat DST gaps and overlaps as observable behavior. Add boundary tests for
  any code that constructs or rewrites local date/time fields.
- Keep public examples compilable. Update their owning tests when a public API
  or documented behavior changes.

## Workflow

1. Find the behavior owner, callers, tests, and applicable documentation.
2. Make the smallest coherent change; do not add speculative abstractions.
3. Run the narrowest relevant checks, then inspect the final diff.
4. For public API, behavior, or terminology changes, update the sources named
   in `doc/README.md`. Do not add plans to the public repository. Add an ADR
   only for an accepted, durable decision that meets the criteria in
   `doc/agents/domain.md` and has explicit maintainer approval.

## Git safety

- Stage only explicit, reviewed paths; inspect both `git diff --check` and
  `git diff --cached` before a commit.
- Never use reset, clean, checkout/restore, force-push, merge, tag, publish, or
  destructive filesystem commands unless the user has explicitly requested the
  exact operation.
- Generated `doc/api/` output is ignored. Do not edit or stage it.

## Agent skills

### Issue tracker

Issues and specs for this repo live in GitHub Issues. See
`doc/agents/issue-tracker.md`.

### Domain docs

This is a single-context repository. Read `CONTEXT.md` for domain vocabulary
and `doc/README.md` for documentation authority. See `doc/agents/domain.md`.
