# Safe Makefile Root Resolution

status: completed

## Context

The Makefile ignored caller-supplied `REPO_ROOT` values but still trusted
`MAKEFILE_LIST`. Replacing that automatic variable redirected offline checks,
live-source audits, and the reviewed refresh recorder outside the checkout.

## Scope Boundaries

- Do not change mirrored prose, source URLs, fingerprints, verification dates,
  redirects, link targets, or refresh semantics.
- Do not contact Poe during the offline gate.
- Preserve the opt-in live audit and explicit refresh arguments.

## Work Completed

- Reject command-line and environment replacement of `MAKEFILE_LIST`.
- Canonicalize the checked-in Makefile directory through quoted POSIX tools.
- Add a dependency-free shell regression suite for all eight public targets.
- Include the root policy in `make verify` and `make check`.

## Verification Completed

- `make lint`, `make test`, `make build`, `make root-test`, `make verify`, and
  `make check` passed offline.
- All 24 target and `REPO_ROOT` override cases passed from a temporary checkout
  path containing spaces and an apostrophe.
- Command-line and environment `MAKEFILE_LIST` overrides failed closed.
- Shell syntax, strict Git object validation, and reviewed-source secret scans
  passed without changing mirrored content or contacting Poe.
