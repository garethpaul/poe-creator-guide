# LLM Index Title Disambiguation

status: completed

## Context

`llms.txt` listed both the canvas app quick start and the server bot quick start
as `Quick Start`. The source URLs were correct, but duplicate visible titles make
the local index harder to scan and can confuse LLM-oriented retrieval.

## Objectives

- Add a deterministic docs check that rejects duplicate visible titles in
  `llms.txt`.
- Disambiguate the two quick-start entries without changing their source URLs.
- Document the guard in README, VISION, and CHANGES.

## Verification

- `make check`
- `make verify`
- `scripts/check-docs-index.sh`
- `git diff --check`
