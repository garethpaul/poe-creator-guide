#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/poe-docs-index-test.XXXXXX")
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

FIXTURE_ROOT="$WORK_DIR/repository"

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

assert_contains() {
  haystack=$1
  needle=$2
  if ! printf '%s\n' "$haystack" | grep -Fq -- "$needle"; then
    fail "expected output to contain: $needle"
  fi
}

copy_fixture() {
  mkdir -p "$FIXTURE_ROOT"
  (
    cd "$ROOT_DIR"
    tar --exclude .git --exclude .code-review -cf - .
  ) | (
    cd "$FIXTURE_ROOT"
    tar -xf -
  )
}

run_checker() {
  "$FIXTURE_ROOT/scripts/check-docs-index.sh" 2>&1
}

copy_fixture

run_checker >/dev/null

printf '%s\n' '<script>alert("unreviewed")</script>' > "$FIXTURE_ROOT/docs/unreviewed.html"
if output=$(run_checker); then
  fail "unexpected hosted docs files must be rejected"
fi
assert_contains "$output" "unexpected file under docs/: docs/unreviewed.html"
rm "$FIXTURE_ROOT/docs/unreviewed.html"

printf '%s\n' '<script>alert("active")</script>' >> "$FIXTURE_ROOT/docs/welcome-to-poe-for-creators.md"
"$FIXTURE_ROOT/scripts/record-mirror-refresh.sh" welcome-to-poe-for-creators 2026-06-19 >/dev/null
if output=$(run_checker); then
  fail "raw active HTML in mirrored Markdown must be rejected"
fi
assert_contains "$output" "active HTML outside a fenced code block"

printf '%s\n' "Docs index contract tests passed."
