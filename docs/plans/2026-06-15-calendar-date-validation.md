# Calendar Date Validation

Status: In Progress

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

## Verification: Pending

- Run shell syntax checks, focused fixture suites, and the full offline Make
  gate from the repository and an external directory.
- Reject focused hostile mutations across calendar arithmetic, helper wiring,
  pre-network ordering, fixtures, and completed plan evidence.
- Audit the exact diff, generated artifacts, credentials, mirrored content,
  manifest data, conflict markers, and whitespace before commit.
