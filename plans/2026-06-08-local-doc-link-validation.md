# Local Documentation Link Validation

## Status

Completed

## Context

The repository already verified that every mirrored `docs/*.md` page appears in
`llms.txt` and `index.md`, but it did not verify the reverse direction: local
`/docs/<slug>` links inside the index and mirrored pages could point at missing
pages without failing `make verify`.

## Objectives

- Keep the validation offline and shell-only.
- Check every `/docs/<slug>` and `/docs/<slug>#anchor` link in `index.md` and
  mirrored guide pages.
- Fail `make verify` when a local docs link points to a missing Markdown page.
- Keep source-specific `/edit/...`, `doc:...`, and external links out of scope
  for this pass.

## Verification

- `make verify`
- `scripts/check-docs-index.sh`
- `git diff --check`
