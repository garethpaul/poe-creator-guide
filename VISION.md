## Poe Creator Guide Vision

Poe Creator Guide is a documentation mirror and index for Poe creator docs,
including server bots, prompt bots, canvas apps, monetization, file upload,
protocol details, embedding, and recommended settings.

The repository is useful as a compact docs bundle for search, browsing, and
LLM-oriented consumption through files such as `llms.txt` and the generated
Markdown pages.

The goal is to keep the documentation mirror navigable, attributable, and easy
to refresh when source docs change.

The current focus is:

Priority:

- Preserve the generated docs under `docs/`
- Keep `llms.txt` and the index aligned with available pages
- Keep `llms.txt` titles unique enough for LLM-oriented consumption
- Keep `llms.txt` source URLs unique so mirrored source pages are not listed
  with conflicting summaries
- Maintain `make check`, `make verify`, and `make build` as the docs-index,
  source-link, and local-link validation gates
- Keep local heading fragments aligned with mirrored Markdown headings
- Keep mirrored guide links on validated `/docs/...` paths instead of legacy
  `doc:` or parent-relative Markdown targets
- Run the canonical dependency-free docs gate in hosted CI with read-only
  permissions and pinned third-party actions
- Record new maintenance plans under `docs/plans/`
- Avoid hand-editing generated pages without noting the source
- Keep per-page source attribution comments in mirrored docs
- Keep each mirrored page's source attribution as the first line
- Keep source links visible for each document
- Keep each index entry's local page link paired with its canonical source URL
- Keep each source URL in the index tied to a checked-in mirrored page
- Keep duplicate local or source entries out of the local index
- Keep the HTML redirect entry point tied to a checked-in mirrored document
- Keep HTML redirect references aligned to one mirrored document

Next priorities:

- Add a refresh script or documented generation process
- Record generation timestamps
- Expand validation beyond attribution placement into front matter and source freshness
- Clarify which files are generated versus maintained by hand

Contribution rules:

- One PR = one focused docs refresh, index, validation, or metadata change.
- Keep copied documentation attributable to its source.
- Do not mix generated refreshes with unrelated edits.
- Preserve filenames and links unless the source structure changes.

## Security And Responsible Use

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Creator documentation can influence production bot behavior. The mirror should
avoid stale or unattributed guidance and should make source freshness visible to
readers.

## What We Will Not Merge (For Now)

- Unattributed copied docs
- Silent generated rewrites
- Broken source links
- Opinionated guidance mixed into mirrored source content

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
