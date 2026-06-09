# Index Source URL Validation

status: completed

## Context

The docs check verifies that each mirrored page has a visible source URL in
`index.md`, but it did not check the reverse direction for source URLs that
appear only in the index. A stale Poe source URL could stay visible in the
index after its mirrored page was removed.

## Goals

- Require each `https://creator.poe.com/docs/<slug>` source URL in `index.md`
  to resolve to a checked-in `docs/<slug>.md` mirror.
- Add a `make build` target for the docs-only static verification gate.
- Keep the guard offline and implemented in `scripts/check-docs-index.sh`.
- Record the completed validation plan under `docs/plans/`.
- Document the reverse source-URL guard in README, VISION, SECURITY, and
  CHANGES.

## Verification

- Temp-copy red check with a stale `index.md` source URL.
- Red `make build` before adding the target.
- `sh -n scripts/check-docs-index.sh`
- `scripts/check-docs-index.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
