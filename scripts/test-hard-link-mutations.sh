#!/usr/bin/env sh
# shellcheck disable=SC2016
set -eu

if [ "${HARD_LINK_MUTATION_CHILD:-0}" = 1 ]; then
  exit 0
fi

ROOT_DIR=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/poe-hard-link-mutations.XXXXXX")
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

remove_line() {
  pattern=$1
  file=$2
  temporary="$file.tmp"
  grep -vF -- "$pattern" "$file" > "$temporary"
  mv "$temporary" "$file"
}

run_mutation() {
  name=$1
  pattern=$2
  relative_file=$3
  fixture="$WORK_DIR/$name"
  mkdir -p "$fixture"
  (
    cd "$ROOT_DIR"
    tar --exclude .git --exclude .explore -cf - .
  ) | (
    cd "$fixture"
    tar -xf -
  )
  remove_line "$pattern" "$fixture/$relative_file"
  if HARD_LINK_MUTATION_CHILD=1 /usr/bin/make -C "$fixture" check >/dev/null 2>&1; then
    fail "mutation survived: $name"
  fi
  printf 'Rejected mutation: %s\n' "$name"
}

run_mutation hosted-guard \
  '      printf '\''%s\n'\'' "$docs_file"' \
  scripts/check-docs-index.sh
run_mutation live-audit-guard \
  '  [ "$mirror_link_count" -eq 1 ] || fail "source manifest references hard-linked mirror: docs/$slug.md"' \
  scripts/check-source-availability.sh
run_mutation refresh-guard \
  '[ "$mirror_link_count" -eq 1 ] || fail "mirror must not be hard linked: docs/$slug.md"' \
  scripts/record-mirror-refresh.sh
run_mutation helper-contract \
  'file_link_count() {' \
  scripts/file-link-count.sh
run_mutation fixture-contract \
  '  "the live audit must reject hard-linked mirrors"' \
  scripts/test-source-availability.sh
run_mutation completed-plan \
  'Status: Completed' \
  docs/plans/2026-06-26-hard-link-ownership.md

printf '%s\n' 'Hard-link mutation tests passed for 6 hostile changes.'
