# Changes

## 2026-06-08

- Required each mirrored page's canonical source URL to remain visible in
  `index.md` during offline docs validation.
- Added `index.html` redirect validation so the GitHub Pages entry point must
  target a checked-in mirrored document.
- Added reverse local-link validation so `/docs/<slug>` links in the index and
  mirrored pages must point to checked-in docs.
- Added a canonical `docs/plans/` baseline and wired the docs check to require
  at least one completed plan there.
- Added `make check` as an alias for the existing docs verification gate.
- Replaced the placeholder Markdown index with a local index covering all mirrored Poe creator docs.
- Added `scripts/check-docs-index.sh` and `make verify` to keep `docs/*.md`, `llms.txt`, and `index.md` aligned.
- Updated README and vision notes with the new static documentation validation workflow.
