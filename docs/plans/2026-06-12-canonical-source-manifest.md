# Canonical source manifest and live audit

status: completed

## Context

A live audit on 2026-06-12 found that 24 mirrored source URLs redirect to new
sectioned paths and `fastapi_poe-python-reference` returns HTTP 404 at its old
path. The offline checker derives source URLs from local slugs, so it cannot
represent canonical upstream paths or detect this drift.

## Decision

1. Add a tab-separated manifest mapping every local slug to one canonical Poe
   Creator Platform URL and its verification date.
2. Update page attributions, index source links, and `llms.txt` to use the
   canonical URLs while preserving local mirror slugs.
3. Make the offline checker validate manifest shape, uniqueness, coverage,
   canonical attribution, and index/LLM consistency without network access.
4. Add an opt-in `make check-sources` command that follows redirects and
   requires HTTP 200 at the recorded canonical URL.
5. Keep canonical GitHub Actions fully offline and credential-free.

## Verification

- `make check-sources` followed redirects and confirmed HTTP 200 at all 25
  recorded canonical URLs with no remaining redirect.
- `sh -n` and `dash -n` passed for both source-check scripts.
- The offline checker validates all 25 manifest rows against 25 mirrored pages,
  first-line attributions, `index.md`, and `llms.txt` without network access.
- Twelve hostile mutations covering missing and duplicate manifest data,
  canonical URL and date drift, page/index/LLM attribution, Makefile and live
  audit wiring, documentation, and plan status were all rejected.
- The historical completed CI plan now also carries one canonical
  `status: completed` line while retaining its existing status heading.
