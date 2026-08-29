# Issue tracker: GitHub

Issues and specifications for this repository live in GitHub Issues. Use the
`gh` CLI from this checkout; it infers the repository from `origin`.

## Authorization

Reading and listing issues are allowed when needed for the current task.
Creating, commenting on, editing, or closing an issue changes remote state and
requires an explicit user or maintainer request. The command examples below do
not grant that authorization.

## Conventions

- **Create**: `gh issue create --title "..." --body "..."`
- **Read**: `gh issue view <number> --comments`
- **List**: `gh issue list --state open`
- **Comment**: `gh issue comment <number> --body "..."`
- **Update labels**: `gh issue edit <number> --add-label "..."` or
  `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

## Specification source

Use GitHub Issues as the durable source for repository specifications. A pull
request should link the relevant issue when one exists; it is not a replacement
for missing requirements.

## Skill routing

For an authorized issue-tracker publication, create a GitHub issue. To fetch a
relevant ticket, run `gh issue view <number> --comments`.
