# Index Entry Deduplication

status: completed
date: 2026-06-09

## Context

The docs checker already verifies that every mirrored page appears in
`index.md` and that local links stay paired with canonical Poe source URLs. It
did not reject duplicate local or source entries, so a page could be listed
twice with conflicting summary context while still satisfying presence checks.

## Changes

- Added duplicate-source-URL checks for `index.md`.
- Added duplicate-local-doc-link checks for `index.md`, normalizing `.html`
  suffixes and anchors before comparison.
- Documented the index-entry deduplication guard in the maintenance docs.

## Verification

- `make lint`
- `make test`
- `make build`
- `make check`
