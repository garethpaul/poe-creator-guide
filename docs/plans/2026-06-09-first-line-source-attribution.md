# First-Line Source Attribution

status: completed

## Context

Each mirrored Poe creator guide page has a canonical source comment, but the
offline docs check only required that comment to appear somewhere in the file.
If the comment drifted below copied content or appeared more than once, readers
opening an individual page could miss the source context.

## Goals

- Require exactly one source attribution comment per mirrored `docs/*.md` page.
- Require the attribution comment to be the first line of the mirrored page.
- Keep the check offline and implemented in `scripts/check-docs-index.sh`.
- Document the attribution placement guard in README, VISION, SECURITY, and
  CHANGES.

## Verification

- `scripts/check-docs-index.sh`
- `make check`
- `make verify`
- `git diff --check`
