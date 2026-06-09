# poe-creator-guide

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/poe-creator-guide` is a static web project. The checked-in files describe a static web project with the structure summarized below.

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `main` branch. The project language mix found during review was: no dominant source language detected.

## Repository Contents

- `README.md` - project overview and local usage notes
- `CHANGES.md` - notable maintenance changes
- `Makefile` - local verification entry points
- `docs` - source or example code
- `index.md` and `index.html` - local documentation entry points
- `llms.txt` - LLM-oriented source index
- `docs/plans` - canonical completed maintenance plans
- `plans` - earlier completed maintenance plans retained for history
- `scripts` - deterministic docs validation checks
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: docs, scripts
- Dependency and build manifests: Makefile
- Entry points or build surfaces: Makefile, index.html, index.md, llms.txt
- Test-looking files: scripts/check-docs-index.sh, docs/poe-protocol-specification.md

## Getting Started

### Prerequisites

- Git
- POSIX shell and `make`

### Setup

```bash
git clone https://github.com/garethpaul/poe-creator-guide.git
cd poe-creator-guide
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Open `index.md` for the local Markdown index, or `index.html` for the GitHub Pages redirect.
- Read `llms.txt` for source URLs and short page summaries.

## Testing and Verification

- Run `make check` or `make verify` before committing documentation index changes.
- The verification gate runs `scripts/check-docs-index.sh`, which confirms every `docs/*.md` page is represented by both `llms.txt` and `index.md`, each mirrored page has a source attribution comment, each page's source URL remains visible in `index.md`, local `/docs/<slug>` links point to checked-in pages, and `docs/plans/` contains a completed maintenance plan.
- The same gate requires unique visible `llms.txt` titles so similarly named
  source pages stay distinguishable for local browsing and LLM-oriented use.
- The same gate validates `index.html` redirect links so the GitHub Pages entry
  point cannot drift to a missing mirrored document.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- Detected references to OpenAI. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.

## Security and Privacy Notes

- Review changes touching authentication or token handling; examples from the scan include docs/fastapi_poe-python-reference.md, docs/how-we-cover-your-costs.md, docs/poe-protocol-specification.md, docs/quick-start.md, and 1 more.
- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include docs/accessing-other-bots-on-poe.md, docs/examples.md, docs/fastapi_poe-python-reference.md, docs/poe-protocol-specification.md, and 3 more.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include _config.yml, docs/accessing-other-bots-on-poe.md, docs/best-practices-for-video-generation-prompts.md, docs/best-practices-image-generation-bots.md, and 6 more.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include docs/accessing-other-bots-on-poe.md, docs/best-practice-text-generation.md, docs/best-practices-for-video-generation-prompts.md, docs/best-practices-image-generation-bots.md, and 6 more.
- Review changes touching database, model, or persistence code; examples from the scan include docs/best-practice-text-generation.md, docs/canvas-app-quick-start.md, docs/fastapi_poe-python-reference.md, docs/how-to-get-distribution.md, and 5 more.

## Maintenance Notes

- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `CHANGES.md` for maintenance history.
- See `docs/plans/2026-06-08-docs-plan-location-baseline.md` for the canonical
  docs-plan baseline and `plans/` for earlier historical plans.
- See `docs/plans/2026-06-09-index-html-redirect-validation.md` for the
  `index.html` redirect validation guard.
- See `docs/plans/2026-06-09-llms-title-disambiguation.md` for the
  `llms.txt` duplicate-title guard.
- See `docs/plans/2026-06-09-page-source-attribution.md` for the
  per-page source attribution guard.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
