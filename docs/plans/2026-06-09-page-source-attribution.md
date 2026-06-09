---
title: Page Source Attribution Guard
date: 2026-06-09
status: completed
---

# Page Source Attribution Guard

## Context

The repository mirrors Poe creator documentation for local browsing and
LLM-oriented consumption. The index and `llms.txt` already expose canonical
source URLs, but individual mirrored pages should remain attributable when read
outside the index.

## Objectives

- Add a source attribution comment to each mirrored `docs/*.md` page.
- Extend `scripts/check-docs-index.sh` so future mirrored pages must keep the
  exact source attribution comment.
- Document the guard in the README, vision, security policy, and change log.

## Verification

- `make check`
- `git diff --check`
