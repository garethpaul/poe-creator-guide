# Hosted Content Boundary

Status: Completed

## Problem

The offline docs gate validates known mirrored Markdown pages and source
manifest rows, but it did not reject extra hosted files under `docs/`. A future
change could add an unreviewed `docs/*.html` file or raw active Markdown HTML
while the existing mirror, index, and fingerprint checks still passed. Source
URL validation also accepted any string with the `https://creator.poe.com/docs/`
prefix, including dot-segment paths that can be normalized away from the
reviewed docs path.

## Requirements

1. Reject unexpected files and symbolic links under `docs/`, while preserving
   reviewed Markdown pages, completed plans, `docs/sources.tsv`, and
   `docs/readme-overview.svg`.
2. Reject raw active Markdown HTML outside fenced code examples.
3. Share canonical Poe docs URL validation across the offline manifest check,
   opt-in live audit, and mirror refresh recorder.
4. Add mutation-sensitive fixture tests for hosted-file and active-content
   regressions, plus a live-audit fixture for dot-segment source URLs.
5. Keep the scripts POSIX-shell compatible and caller-directory independent.

## Work Completed

- Added `scripts/test-docs-index.sh`, wired it into `make test`, and covered
  both unexpected hosted files and raw active Markdown HTML after a reviewed
  fingerprint refresh.
- Added hosted `docs/` allow-list validation and repository-wide Markdown
  active-content scanning that ignores fenced blocks and inline code spans.
- Added `scripts/source-url.sh` and reused it from offline validation, the live
  audit, and the refresh recorder to reject dot segments, encoded paths, query
  strings, fragments, and non-docs source URLs.
- Cleaned up shell root detection so `shellcheck scripts/*.sh` is clean.

## Verification: Completed

- `scripts/test-docs-index.sh`, `scripts/test-source-availability.sh`, and
  `scripts/test-mirror-refresh.sh` passed.
- `make check` passed with the docs-index fixture suite included.
- `sh -n scripts/*.sh`, `dash -n scripts/*.sh`, `shellcheck scripts/*.sh`, and
  `git diff --check` passed.
- The new tests first failed against the prior behavior for unexpected hosted
  files, raw active Markdown HTML, and dot-segment source URLs, then passed
  after the boundary fixes.
