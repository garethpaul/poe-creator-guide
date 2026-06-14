---
title: Location-Independent Make Gates
type: fix
date: 2026-06-14
---

# Location-Independent Make Gates

status: planned

## Summary

Make every offline, opt-in live-audit, and mirror-refresh Make target resolve
the repository that owns the Makefile instead of the caller's directory.

## Problem Frame

The underlying validators derive their own repository roots, but the Makefile
launches each script with a caller-relative path. Absolute Makefile invocation
therefore fails before those portable scripts can run.

## Requirements

- R1. Derive an override-protected absolute root from the loaded Makefile.
- R2. Root the live source audit, mirror refresh recorder, offline validator,
  and both fixture suites while preserving target dependencies and parameters.
- R3. Extend the offline validator with exact contracts for root derivation and
  every rooted recipe.
- R4. Preserve mirrored pages, source rows, fingerprints, URLs, verification
  dates, indexes, redirects, workflow, and network opt-in policy.

## Assumptions

- The hosted Ubuntu Make implementation supports the loaded-Makefile root
  pattern used by the repository fleet.
- The existing scripts remain independently portable and keep their own root
  derivation; the Makefile only controls invocation location.

## Implementation Units

### U1. Root all script recipes

**Files:** `Makefile`

Use one override-protected root for `check-sources`, `record-refresh`, `lint`,
and both test scripts. Keep `SLUG` and `VERIFIED_AT` validation and all alias
dependencies unchanged.

**Test scenarios:**

- Run every offline alias from the repository root and an external directory.
- Exercise `check-sources` externally with a deterministic fake curl so no live
  network is required.
- Confirm external `record-refresh` usage validation and its dry-run command
  retain parameters while selecting the repository-owned root.

### U2. Enforce and record the contract

**Files:** `scripts/check-docs-index.sh`,
`docs/plans/2026-06-14-location-independent-make.md`

Require exact root and recipe fragments, reject isolated mutations, and record
completed evidence only after final validation.

**Test scenarios:**

- Mutate root derivation and each rooted script recipe independently.
- Run POSIX shell syntax and both fixture suites.
- Confirm mirrored content, manifest, indexes, LLM listing, redirects,
  workflow, prior plans, artifacts, credentials, and dependencies are unchanged.

## Scope Boundaries

- Do not fetch or replace mirrored prose.
- Do not change source metadata, fingerprints, verification dates, or canonical
  URLs.
- Do not make live network access part of the default verification gate.

## Verification

Completion requires all offline aliases from root and `/tmp`, deterministic
external live-audit wiring, record-refresh usage and dry-run checks, six hostile
Make mutations, shell syntax, and exact protected-content audits.
