# Changes

## 2026-06-17

- Rejected symbolic-link mirrors in offline validation, opt-in live audits, and
  reviewed refresh recording so fingerprints remain bound to checked-in files.
- Added isolated audit and refresh fixtures proving symlink rejection occurs
  before network access or manifest mutation.
- Made the opt-in live source audit validate the complete manifest, safe local
  mirror boundary, and all fingerprints before issuing any network request.
- Added offline fixtures for empty, malformed, duplicate, traversal-shaped,
  noncanonical, missing-mirror, and later-row preflight failures.

## 2026-06-13

- Added an offline reviewed-mirror refresh recorder, atomic single-row manifest
  updates, a Make target, and fixture coverage for success and rejection paths.
- Added network-free live source audit tests for curl arguments, HTTP failures,
  redirects, transport errors, and fingerprint preflight ordering.
- Added mirrored content fingerprints to every canonical source row and made
  offline and opt-in live validation reject local snapshot drift.

## 2026-06-12

- Replaced 25 legacy derived source URLs with reviewed canonical sectioned Poe
  URLs and recorded their live-verification date in `docs/sources.tsv`.
- Added offline manifest coverage and consistency validation plus an opt-in
  `make check-sources` live HTTP 200 audit; canonical GitHub Actions remains
  dependency-free and network-free.
- Repaired two broken mirrored guide links that used legacy `doc:` and
  parent-relative Markdown targets.
- Added an offline guard requiring mirrored local guide links to use validated
  `/docs/...` paths.

## 2026-06-10

- Added GitHub Actions offline documentation validation for pushes, pull
  requests, and manual dispatches, with read-only permissions and pinned,
  credential-free checkout.
- Extended the docs checker to preserve the exact hosted workflow contract and
  both completed CI maintenance plans.
- Added `index.html` redirect target consistency validation so refresh,
  canonical, and fallback links must point to the same mirrored document.
- Added offline local heading-fragment validation and repaired stale section
  links after guide content moved to dedicated pages.
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
