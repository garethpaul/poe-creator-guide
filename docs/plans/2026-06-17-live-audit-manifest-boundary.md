# Live Audit Manifest Boundary

Status: Planned

## Problem

`make check-sources` invokes `scripts/check-source-availability.sh` directly.
Unlike the offline index checker, the live audit currently trusts manifest
slugs and source URLs while reading local files and issuing requests. It also
validates and requests one row at a time, so an invalid later row can be found
only after an earlier canonical URL has already been contacted.

## Requirements

1. Validate the complete `docs/sources.tsv` structure before invoking `curl`:
   at least one row, exactly four non-empty tab-separated fields, unique safe
   local slugs, unique canonical `https://creator.poe.com/docs/` URLs, valid
   Gregorian dates, lowercase SHA-256 fingerprints, and existing
   `docs/<slug>.md` mirrors.
2. Verify every local mirror fingerprint before beginning the network phase.
3. Preserve the existing HTTP 200, no-redirect, timeout, retry, and canonical
   URL behavior once preflight validation succeeds.
4. Keep the audit dependency-free, POSIX-shell compatible, caller-directory
   independent, and explicitly opt-in.
5. Add deterministic fixtures proving malformed rows, traversal-shaped slugs,
   noncanonical URLs, missing mirrors, and later-row failures are rejected
   before any network invocation.
6. Add mutation-sensitive offline contracts for the preflight boundary and
   completed plan evidence.

## Implementation Units

### U1. Complete Manifest Preflight

Refactor `scripts/check-source-availability.sh` into a local validation pass
followed by the existing request pass. Keep validation messages specific enough
to identify the offending row or slug.

### U2. Boundary Regression Coverage

Extend `scripts/test-source-availability.sh` with isolated manifest fixtures.
Use the existing fake `curl` log to prove empty, malformed, duplicate, or
unsafe input fails before the first request, including when a valid row
precedes an invalid row.

### U3. Durable Contracts And Guidance

Update `scripts/check-docs-index.sh`, `README.md`, and `CHANGES.md` so the
standalone live-audit boundary and completed verification evidence remain part
of the repository baseline.

## Scope Boundaries

- Do not change mirrored document content, source URLs, verification dates, or
  fingerprints.
- Do not perform a live network audit during implementation or validation.
- Do not add dependencies or platform-specific shell behavior.
- Do not change the opt-in nature of `make check-sources`.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification Plan

- `sh -n` and `dash -n` for every changed shell script.
- Focused source-audit fixtures covering valid requests and all preflight
  rejection paths, including a later invalid row with zero fake-curl calls.
- Full `make check` from the repository root and through the absolute Makefile
  path from an external directory.
- Hostile mutations across row shape, slug safety, canonical URL enforcement,
  mirror existence, two-pass ordering, baseline wiring, and plan status.
- Final exact-path diff, generated-artifact, secret-pattern, manifest-data,
  mirrored-content, dependency, and whitespace audits.
