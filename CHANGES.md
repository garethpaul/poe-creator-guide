# Changes

## 2026-06-08

- Added reverse local-link validation so `/docs/<slug>` links in the index and
  mirrored pages must point to checked-in docs.
- Replaced the placeholder Markdown index with a local index covering all mirrored Poe creator docs.
- Added `scripts/check-docs-index.sh` and `make verify` to keep `docs/*.md`, `llms.txt`, and `index.md` aligned.
- Updated README and vision notes with the new static documentation validation workflow.
