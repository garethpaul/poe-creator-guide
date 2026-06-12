# Index HTML Target Consistency

status: completed

## Context

The docs check already verified that each `/docs/<slug>` reference in
`index.html` points to a checked-in mirrored page. It did not require the meta
refresh target, canonical URL, and fallback link to agree with each other, so
the static entry point could send different readers to different valid pages.

## Goals

- Normalize the `index.html` docs references before validation.
- Require all redirect references to point to one mirrored document.
- Keep the existing missing-page validation for each redirect reference.
- Record the new guard in README, SECURITY, VISION, and CHANGES.

## Verification

- `scripts/check-docs-index.sh`
- `make check`
- `make verify`
- `git diff --check`
