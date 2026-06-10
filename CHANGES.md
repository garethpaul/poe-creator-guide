# Changes

## 2026-06-10

- Added hosted offline documentation validation for pushes and pull requests,
  with read-only permissions and a pinned checkout action.
- Extended the docs checker to preserve the hosted workflow contract and its
  completed maintenance plan.
- Added `index.html` redirect target consistency validation so refresh,
  canonical, and fallback links must point to the same mirrored document.

## 2026-06-09

- Added reverse source-URL validation so every Poe source URL in `index.md`
  maps to a checked-in mirrored page.
- Added duplicate local/source entry validation for `index.md`.
- Added a static `make build` gate for docs-only verification.

## 2026-06-08

- Added `llms.txt` duplicate source URL validation so each mirrored source page
  appears once in the LLM-oriented index.
- Added index source-pair validation so each local docs link stays paired with
  its canonical Poe source URL.
- Required each mirrored page's canonical source URL to remain visible in
  `index.md` during offline docs validation.
- Added per-page source attribution comments and validation for mirrored docs.
- Required mirrored page source attribution comments to be first-line and
  unique within each page.
- Added `index.html` redirect validation so the GitHub Pages entry point must
  target a checked-in mirrored document.
- Added `llms.txt` duplicate-title validation and disambiguated the canvas and
  server bot quick-start entries.
- Added reverse local-link validation so `/docs/<slug>` links in the index and
  mirrored pages must point to checked-in docs.
- Added a canonical `docs/plans/` baseline and wired the docs check to require
  at least one completed plan there.
- Added `make check` as an alias for the existing docs verification gate.
- Replaced the placeholder Markdown index with a local index covering all mirrored Poe creator docs.
- Added `scripts/check-docs-index.sh` and `make verify` to keep `docs/*.md`, `llms.txt`, and `index.md` aligned.
- Updated README and vision notes with the new static documentation validation workflow.
