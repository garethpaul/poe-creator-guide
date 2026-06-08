# poe-creator-guide

## Overview

`garethpaul/poe-creator-guide` is a static web project. The checked-in files describe a static web project with the structure summarized below.

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `main` branch. The project language mix found during review was: no dominant source language detected.

## Repository Contents

- `README.md` - project overview and local usage notes
- `docs` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: docs
- Dependency and build manifests: none detected
- Entry points or build surfaces: none detected
- Test-looking files: docs/poe-protocol-specification.md

## Getting Started

### Prerequisites

- Git

### Setup

```bash
git clone https://github.com/garethpaul/poe-creator-guide.git
cd poe-creator-guide
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- No single runtime entry point was identified. Start by reading the source files and manifests listed above.

## Testing and Verification

- No dedicated automated test command was identified from the checked-in files. Verify changes by running the relevant build or manually exercising the sample.

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

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.

