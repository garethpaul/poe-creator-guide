# Mirror Symlink Boundary

Status: In Progress

## Problem

The live source audit and mirror refresh recorder require `docs/<slug>.md` to
exist, but their `-f` checks follow symbolic links. A manifest row can therefore
cause either command to hash content outside the repository's `docs/` mirror
set while still appearing to validate a local mirror.

## Requirements

1. Reject symbolic-link mirrors before hashing content in both the live audit
   and refresh recorder.
2. Preserve existing missing-file, attribution, fingerprint, and pre-network
   validation behavior.
3. Keep the scripts caller-directory independent and compatible with the
   repository's POSIX shell gates.
4. Add deterministic fixtures proving symlink mirrors fail and that the live
   audit makes no network request for them.
5. Add mutation-sensitive baseline contracts and completed verification
   evidence.

## Implementation Units

### U1. Mirror Type Validation

Require each selected mirror to be a regular file and not a symbolic link in
`check-source-availability.sh` and `record-mirror-refresh.sh`.

### U2. Regression Coverage

Extend both isolated fixture suites with an external target and a mirror
symlink. Assert that the audit rejects it before fake `curl` is invoked and the
recorder leaves the manifest unchanged.

### U3. Durable Evidence

Update the baseline checker, maintainer guidance, changelog, and this plan with
the exact completed validation and hostile-mutation results.

## Verification Plan

- Run `sh -n` and `dash -n` for every changed shell script.
- Run the focused source-audit and mirror-refresh fixture suites.
- Run full `make check` from the repository root and through the absolute
  Makefile path from an external directory.
- Reject mutations that remove either runtime symlink guard, either fixture,
  the baseline contract, or completed plan evidence.
- Audit the exact diff, generated artifacts, secret patterns, whitespace, and
  manifest/mirror preservation before committing.

## Scope Boundaries

- Do not change source URLs, mirror content, manifest dates, or fingerprints.
- Do not perform the opt-in live network audit.
- Do not add dependencies or broaden the accepted mirror path format.
- Do not merge or close stacked pull requests without explicit authorization.
