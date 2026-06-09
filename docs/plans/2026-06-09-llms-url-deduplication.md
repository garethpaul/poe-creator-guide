# LLMs URL Deduplication

status: completed

## Context

`llms.txt` is the compact source index for LLM-oriented consumption. The checker
already required every mirrored source URL to resolve to a checked-in page and
required visible titles to be unique, but the URL validation used a unique URL
set. That meant duplicate source URLs could pass while carrying conflicting
summaries.

## Objectives

- Fail the docs check when `llms.txt` lists the same Poe creator source URL more
  than once.
- Keep existing page, title, local-link, redirect, and attribution validation.
- Document the duplicate source URL guard in README, VISION, CHANGES, and this
  completed plan.

## Verification

- `sh -n scripts/check-docs-index.sh`
- `scripts/check-docs-index.sh`
- `make lint`
- `make test`
- `make verify`
- `make check`
- `git diff --check`
