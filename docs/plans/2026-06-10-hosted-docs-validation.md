# Hosted Documentation Validation

status: completed
date: 2026-06-10

## Context

The repository had a comprehensive offline documentation validator, but the
default branch did not run it automatically for pushes and pull requests.
Documentation, index, attribution, or redirect regressions could therefore be
merged without exercising the canonical `make check` gate.

## Changes

- Added a GitHub Actions workflow that runs `make check` on a fixed Ubuntu
  runner without installing dependencies or contacting external services.
- Limited the workflow token to read-only repository contents access.
- Pinned the checkout action to a reviewed commit and added concurrency and
  timeout limits.
- Extended the offline validator to require the hosted workflow, pinned action,
  read-only permission, canonical command, and this completed plan.

## Verification

- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
