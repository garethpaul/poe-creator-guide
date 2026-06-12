# Poe Creator Guide CI Baseline

## Status: Completed

## Context

`poe-creator-guide` has an offline documentation index baseline behind
`make check`. The repository needs that baseline to run in GitHub Actions so
mirrored docs, source links, indexes, redirects, and completed plans are checked
before review.

## Objectives

- Run the existing docs validation baseline in GitHub Actions.
- Keep the hosted job dependency-free and offline.
- Make the workflow presence part of the docs-index baseline contract.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Added commit-pinned checkout with credential persistence disabled, read-only
  permissions, concurrency cancellation, and a bounded Ubuntu runner.
- Reused the existing shell validator without adding a package manager or
  network dependency.
- Extended `scripts/check-docs-index.sh` to require the CI workflow and this
  completed plan, including its exact least-privilege structure.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `scripts/check-docs-index.sh`
- `git diff --check`

## Follow-Up Candidates

- Add a docs refresh workflow only after the mirror generation process is
  documented and reproducible.
