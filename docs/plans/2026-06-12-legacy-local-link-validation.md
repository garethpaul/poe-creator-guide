# Legacy Local Link Validation

status: completed

## Context

The guide validates root-relative `/docs/...` links and heading fragments, but
two mirrored pages still contain legacy local-link forms: a `doc:` target and a
parent-relative Markdown target. Neither resolves correctly in the generated
GitHub Pages guide, and both bypass the current local document checks.

## Priority

Broken navigation in protocol and prompt-writing documentation prevents readers
from reaching related guidance and weakens confidence in the mirrored index.
The offline gate should reject these legacy forms before publication.

## Prioritized Engineering Backlog

1. Normalize the existing `doc:` and parent-relative guide links now.
2. Reject future legacy local-link forms through `make check`.
3. Add a full Markdown parser only if link syntax grows beyond the current
   dependency-free validator's reliable scope.

## Requirements

- R1. Mirrored guide links to other mirrored pages must use `/docs/<slug>` or
  `/docs/<slug>#<fragment>`.
- R2. `doc:` Markdown targets must fail validation.
- R3. Parent-relative `../*.md` Markdown targets must fail validation.
- R4. Existing root-relative document and fragment validation must remain
  unchanged.
- R5. The validator must remain dependency-free and offline.
- R6. README, security guidance, vision, changes, and the completed plan must
  document the guard.

## Scope Boundaries

- Do not rewrite external links, image URLs, or dynamic links inside examples.
- Do not change mirrored prose beyond the two broken link targets.
- Do not add dependencies.

## Verification

- `scripts/check-docs-index.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`

## Work Completed

- Normalized the prompt-bot and bot-query guide links to root-relative
  `/docs/...` targets.
- Added a dependency-free validator guard for `doc:` and parent-relative
  Markdown link forms.
- Preserved existing document, fragment, source attribution, index, and redirect
  checks.
- Updated maintenance and security documentation for the new guard.
