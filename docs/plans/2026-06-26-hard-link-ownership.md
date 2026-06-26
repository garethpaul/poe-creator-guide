# Hard-Link Ownership Boundary

Status: Completed

## Problem

The hosted docs checker, opt-in live source audit, and reviewed refresh recorder
rejected symbolic-link mirrors but accepted regular files with multiple hard
links. A path inside the checkout could therefore share an inode with a path
outside the repository and change without a repository path replacement.

## Requirements

1. Reject hard-linked hosted docs files during the canonical offline gate.
2. Reject hard-linked mirrors before live network access or manifest mutation.
3. Recheck mirror ownership after hashing at the audit and refresh boundaries.
4. Preserve Linux and macOS shell compatibility without adding dependencies.
5. Add focused behavioral tests and durable source-policy contracts.

## Work Completed

- Added a shared GNU/BSD `stat` helper for portable file link counts.
- Rejected hard-linked hosted docs files and hard-linked manifest mirrors.
- Rechecked mirror link ownership after content hashing in every mirror
  consumer.
- Added isolated fixture coverage for the offline checker, live audit preflight,
  and refresh recorder without contacting Poe or mutating a rejected manifest.

## Verification

- Focused tests first demonstrated acceptance of hard-linked hosted docs files
  and mirrors, then passed after the ownership guards were added.
- `sh -n` and `dash -n` passed for all shell scripts; ShellCheck passed for every
  changed shell script.
- Six hostile mutations, 56 Make authority cases, and `make check` from both the
  repository root and an external caller directory passed.
