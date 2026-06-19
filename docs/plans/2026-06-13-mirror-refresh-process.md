# Mirror Refresh Process

status: completed

## Context

The guide verifies canonical source mappings, mirrored content fingerprints,
local navigation, and live source availability, but it has no reproducible
process for recording an intentionally reviewed mirror refresh. Contributors
must manually edit four-field manifest rows, which risks changing the wrong
slug, dropping another row, or recording a fingerprint before attribution is
valid.

## Requirements

- Add a dependency-free POSIX shell recorder for one reviewed mirror slug and
  verification date.
- Require a valid slug, `YYYY-MM-DD` date, exactly one existing manifest row,
  an existing mirror, and the exact canonical source comment on the first line.
- Recompute the mirror SHA-256 and atomically replace only that row's date and
  fingerprint while preserving its source URL and every other row.
- Add offline fixture tests for success, row preservation, and invalid slug,
  date, missing row, and attribution failures.
- Document the full human-reviewed refresh sequence and expose a Make target.

## Scope Boundaries

- Do not automatically download or replace mirrored prose.
- Do not infer canonical URLs, add manifest rows, reorder the manifest, or run
  live network checks by default.
- Do not weaken content fingerprint or source attribution validation.

## Verification Plan

- Run shell syntax checks, the focused refresh fixture tests, and every Make
  alias.
- Run hostile mutations against argument validation, attribution, atomic row
  selection, hashing, tests, documentation, and completed evidence.
- Confirm no mirrored page, source URL, index, LLM listing, HTML redirect,
  workflow, or existing manifest row changes in the implementation diff.
- Run generated-artifact, secret, and `git diff --check` scans.

## Work Completed

- Added `scripts/record-mirror-refresh.sh` to validate one slug, date, unique
  manifest row, mirror, canonical attribution, and SHA-256 before atomically
  replacing only the selected manifest row.
- Added `scripts/test-mirror-refresh.sh` with isolated success, unrelated-row,
  invalid slug/date, missing row, attribution, and duplicate-row fixtures.
- Added the parameterized `make record-refresh` target and documented the
  human-reviewed source comparison, recording, diff review, offline check, and
  optional live audit sequence.
- Extended the offline validator with exact recorder, fixture, Make,
  documentation, and completed-plan contracts.

## Verification Completed

- `sh -n` and focused `scripts/test-mirror-refresh.sh` passed.
- `make lint`, `make test`, `make build`, `make verify`, and `make check` passed
  the 25-page offline mirror/index/fingerprint gate and both fixture suites.
- Eight focused hostile mutations covering slug validation, unique-row
  selection, attribution, hashing, atomic replacement, fixture coverage, Make
  wiring, and plan status were rejected.
- `git diff --check`, shell syntax, exact-path, generated-artifact, secret,
  mirrored-page, source-manifest, index, LLM listing, redirect, workflow, and
  existing-plan preservation scans passed.
