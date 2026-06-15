# Calendar Date Validation

Status: Completed

## Problem

Source verification dates are checked only for the `YYYY-MM-DD` text shape.
The mirror refresh recorder can therefore persist impossible dates such as
`2026-02-30`, and the opt-in live audit does not reject an invalid date until
after it has already contacted the canonical source.

## Requirements

1. Validate real Gregorian calendar dates, including month lengths and leap
   years, without depending on GNU- or BSD-specific `date` options.
2. Reuse one validation implementation in the offline manifest checker, live
   source audit, and mirror refresh recorder.
3. Reject invalid manifest dates before the live audit invokes `curl`.
4. Preserve valid refresh behavior, source URLs, content fingerprints,
   caller-directory independence, and opt-in network policy.
5. Add deterministic fixtures and mutation-sensitive contracts for invalid
   days, valid leap days, helper wiring, and pre-network ordering.

## Scope Boundaries

- Do not refresh mirrored content, source URLs, fingerprints, or dates.
- Do not perform a live source audit or require network access.
- Do not add dependencies or use platform-specific `date` flags.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification: Completed

- `sh -n` and `dash -n` passed for the helper and all changed shell scripts.
- Focused source-audit and refresh fixtures passed impossible-day rejection,
  pre-network ordering, ordinary leap-day, non-leap-century, and leap-century
  cases without live network access.
- Full `make check` passed from the repository root and through the absolute
  Makefile path from `/tmp`.
- Eight focused hostile mutations were rejected across February length,
  Gregorian century rules, all three consumers, fixture wiring, and completed
  plan evidence.
- Final `git diff --check`, generated-artifact, credential-pattern,
  conflict-marker, mirrored-content, manifest-data, and dependency scans passed
  for the intended paths.
