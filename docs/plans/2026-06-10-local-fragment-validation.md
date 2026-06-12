# Local Fragment Validation

status: completed

## Context

The offline link checker verified the target Markdown file for local docs links
but ignored `#fragment` values. Heading changes and content splits could leave
links pointing at nonexistent sections while `make check` still passed.

## Objectives

- Derive anchors from ATX and Setext Markdown headings.
- Normalize heading text to the mirrored Jekyll-style fragment form.
- Reject local docs fragments that do not match a target heading.
- Replace stale functional-guide fragments with links to their dedicated pages.
- Keep the validation fully offline and dependency-free.

## Verification

- `make lint`
- `make test`
- `make build`
- `make check`
- Mutation: change a valid fragment to `#missing-heading` and confirm the gate
  fails.
- `git diff --check`
