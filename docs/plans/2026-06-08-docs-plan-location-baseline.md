# Docs Plan Location Baseline

status: completed

## Context

`poe-creator-guide` mirrors Poe creator documentation as static Markdown pages
and already validates the local docs index with `make check`.

## Risks

- Completed maintenance plans lived only in the top-level `plans/` directory,
  while the broader repository maintenance convention expects
  `docs/plans/*.md`.
- Future contributors could add verification work without a canonical plan file
  under the documented docs tree.

## Work Completed

- Added this completed baseline under `docs/plans/`.
- Kept the existing top-level plans in place for historical continuity.
- Extended `scripts/check-docs-index.sh` so `make check` requires a completed
  `docs/plans/*.md` plan.
- Updated README and changelog notes to point at the canonical plan location.

## Verification

- `make check`
- `scripts/check-docs-index.sh`
- `git diff --check`
