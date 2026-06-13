# Test The Live Source Audit Offline

status: planned

## Summary

Add deterministic, network-free tests for the opt-in canonical Poe source
availability audit. The offline checker currently verifies selected source-code
tokens but does not execute the curl result, redirect, or failure paths.

## Priority

The live audit is the repository's only current-upstream verification path. A
broken curl contract could silently weaken maintenance evidence or make an
intentional source refresh fail without the canonical offline gate noticing.

## Requirements

- R1. Tests must execute the live audit against a temporary one-page manifest
  and mirror without contacting the network.
- R2. A fake curl executable must prove the audit passes the reviewed location,
  output, write-out, 20-second transfer, and two-retry arguments.
- R3. Tests must cover success, non-200 status, redirect, and curl transport
  failure behavior with stable diagnostics.
- R4. Mirror fingerprint validation must run before curl and reject a changed
  fixture without invoking the fake network client.
- R5. `make test`, `make verify`, and `make check` must include the deterministic
  live-audit test while `make check-sources` remains explicitly networked and
  opt-in.
- R6. Canonical source URLs, mirrored page content, verification dates,
  fingerprints, indexes, workflow configuration, and dependencies must remain
  unchanged.
- R7. The baseline checker must reject removal of the harness, Make wiring,
  core failure cases, and completed verification evidence.

## Implementation Units

### U1. Network-Free Harness

**Files:** `scripts/test-source-availability.sh`

- Build an isolated fixture repository and inject a fake `curl` through `PATH`.
- Assert the success contract, curl arguments, stable failures, and fingerprint
  preflight ordering.

### U2. Verification Wiring

**Files:** `Makefile`, `scripts/check-docs-index.sh`

- Run the harness from test-oriented Make gates.
- Add mutation-sensitive source and evidence contracts.

### U3. Guidance And Evidence

**Files:** `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`

- Distinguish the network-free contract tests from the opt-in live audit.

## Scope Boundaries

- Do not make canonical GitHub Actions contact upstream Poe pages.
- Do not change source manifest rows, mirrored pages, indexes, or redirects.
- Do not add dependencies or replace the POSIX shell implementation.

## Verification Plan

- `sh -n` and `dash -n` for the live audit and test harness
- focused fake-curl harness plus all Make gates
- checker execution from an external working directory
- hostile mutations covering Make wiring, curl arguments, failure cases, plan
  status, and verification evidence
- exact-base/protected-path audit, `git diff --check`, and secret,
  captured-prompt, generated-artifact, source-manifest, and dependency scans

## Work Completed

Pending implementation.

## Verification Completed

Pending implementation and verification.
