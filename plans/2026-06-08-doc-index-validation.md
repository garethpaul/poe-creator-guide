# Documentation Index Validation

## Status

Completed

## Context

`poe-creator-guide` mirrors Poe creator documentation as static Markdown pages.
The repository had no local validation command, and `index.md` was still a
placeholder even though `llms.txt` listed the mirrored source pages.

## Objectives

- Add a deterministic local check that does not require network access.
- Require every `docs/*.md` page to have a matching source URL in `llms.txt`.
- Require every mirrored page to appear in the local Markdown index.
- Provide a `make verify` entry point for contributors.

## Verification

- `make verify`
- `scripts/check-docs-index.sh`
- `git diff --check`

## Follow-Up Candidates

- Validate in-repo Markdown links and anchors.
- Record mirror generation timestamps.
- Add source freshness metadata for each mirrored page.
