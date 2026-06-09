# Index HTML Redirect Validation

status: completed

## Context

The Markdown index and mirrored docs already validate local `/docs/<slug>` links,
but the GitHub Pages `index.html` redirect target was outside that check. If the
redirect drifted to a missing document, the static entry point could break while
`make check` still passed.

## Goals

- Validate `index.html` exists.
- Extract `{{ site.baseurl }}/docs/<slug>.html` redirect links.
- Fail the offline docs check when a redirect target has no corresponding
  `docs/<slug>.md` file.
- Record the new guard in README, VISION, and CHANGES.

## Verification

- `scripts/check-docs-index.sh`
- `make check`
- `make verify`
- `git diff --check`
