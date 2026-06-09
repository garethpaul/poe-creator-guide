# Index Source Pair Validation

status: completed

## Context

The docs check required every mirrored page's canonical Poe source URL to appear
somewhere in `index.md`, but that was a broad presence check. A future edit could
shuffle source links between rows while still leaving every URL visible in the
file.

## Goals

- Require each local `/docs/<slug>` index link to be paired with its matching
  canonical Poe source URL.
- Keep the guard offline and implemented in `scripts/check-docs-index.sh`.
- Record the completed validation plan under `docs/plans/`.
- Document the paired-link guard in README, VISION, SECURITY, and CHANGES.

## Verification

- `sh -n scripts/check-docs-index.sh`
- `scripts/check-docs-index.sh`
- `make check`
- `git diff --check`
