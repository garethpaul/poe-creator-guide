# Mirrored Content Fingerprints

status: planned

## Summary

Bind every canonical source row to the exact reviewed local Markdown snapshot
with a SHA-256 fingerprint. Keep hosted validation offline, preserve all 25
mirrored document bodies, and require intentional mirror edits to update the
manifest fingerprint in the same change.

## Problem Frame

`docs/sources.tsv` proves one-to-one slug, canonical URL, and verification-date
coverage, but it does not identify which local content was reviewed. A mirrored
page can change while retaining valid attribution and index links, leaving the
manifest unable to detect unreviewed snapshot drift.

## Requirements

- R1. Add one lowercase 64-character SHA-256 field to every manifest row.
- R2. Compute fingerprints over the complete checked-in `docs/<slug>.md` bytes,
  including the first-line source attribution.
- R3. Verify each fingerprint offline with `sha256sum` or `shasum -a 256`, and
  fail clearly when neither implementation exists.
- R4. Update the opt-in live source audit to accept and validate the four-field
  manifest without changing its HTTP 200/no-redirect behavior.
- R5. Prove the manifest still has exact slug, URL, date, mirror, index, LLM,
  attribution, and page-count coverage.
- R6. Preserve every mirrored page body, canonical URL, verification date,
  workflow, redirect, and dependency-free Make interface.
- R7. Document the fingerprint update rule and enforce completed verification
  evidence through the offline checker.

## Key Technical Decisions

- Store fingerprints in `docs/sources.tsv` rather than a second manifest so
  source identity and snapshot identity remain one atomic record.
- Use a small shell helper with GNU and BSD/macOS command fallbacks instead of
  adding a language runtime or package dependency.
- Treat fingerprints as reviewed snapshot guards, not proof that upstream Poe
  content still matches; `make check-sources` remains availability-only.

## Implementation Units

### U1. Fingerprint Manifest

Extend each manifest row with the current mirror's SHA-256 digest while leaving
slugs, canonical URLs, dates, and mirrored Markdown unchanged.

Test scenarios:
- All 25 rows contain a unique local slug, canonical URL, valid date, and
  lowercase SHA-256 digest.
- Recomputing each mirror digest exactly matches its row.

### U2. Offline And Live Validators

Teach both shell validators to read four fields. The offline gate recomputes
fingerprints; the live audit validates field shape and keeps its existing URL
checks.

Test scenarios:
- A changed mirror byte, malformed digest, missing digest, or extra field fails.
- Missing hash tooling fails with a clear message.
- Existing URL, attribution, index, fragment, redirect, workflow, and plan
  checks remain green.

### U3. Guidance And Durable Evidence

Document when fingerprints must be refreshed, add mutation-sensitive checker
contracts, and record completed evidence only after full validation.

Test scenarios:
- Removing guidance, status, or verification evidence fails the checker.

## Scope Boundaries

- Do not edit the 25 mirrored `docs/*.md` pages or their canonical attributions.
- Do not fetch or compare upstream page bodies in canonical hosted validation.
- Do not change URLs, verification dates, index content, LLM summaries,
  redirects, workflow behavior, Make targets, or add dependencies.

## Verification Plan

- `sh -n` and `dash -n` for both validators
- all Make targets and external-working-directory checker execution
- exact digest recomputation and structured four-field manifest audit
- hostile mutations covering content, digest shape/value, row shape, tooling,
  guidance, status, and evidence
- exact-path and mirrored-page no-diff audit, `git diff --check`, and secret,
  captured-prompt, generated-artifact, URL/date, and dependency-drift scans
