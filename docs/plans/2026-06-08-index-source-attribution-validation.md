# Index Source Attribution Validation

status: completed

## Context

`poe-creator-guide` mirrors Poe creator documentation into local Markdown files.
The existing offline check already required each mirrored page to appear in
`llms.txt` and `index.md`, but it did not fail if the local index omitted the
page's canonical source URL.

## Risks

- Readers could browse the local index without a visible source link for a
  mirrored page.
- Future docs refreshes could accidentally weaken attribution while still
  passing the local verification gate.

## Work Completed

- Extended `scripts/check-docs-index.sh` so every `docs/*.md` page must have
  its `https://creator.poe.com/docs/<slug>` source URL visible in `index.md`.
- Kept the check offline and dependency-free.
- Recorded this completed maintenance plan under `docs/plans/`.

## Verification

- `make check`
- `scripts/check-docs-index.sh`
- `git diff --check`
