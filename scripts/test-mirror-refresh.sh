#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/poe-mirror-refresh-test.XXXXXX")
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

FIXTURE_ROOT="$WORK_DIR/repository"
mkdir -p "$FIXTURE_ROOT/docs" "$FIXTURE_ROOT/scripts"
cp "$ROOT_DIR/scripts/record-mirror-refresh.sh" "$FIXTURE_ROOT/scripts/"
cp "$ROOT_DIR/scripts/iso-date.sh" "$FIXTURE_ROOT/scripts/"
cp "$ROOT_DIR/scripts/source-url.sh" "$FIXTURE_ROOT/scripts/"
cp "$ROOT_DIR/scripts/file-link-count.sh" "$FIXTURE_ROOT/scripts/"
chmod +x "$FIXTURE_ROOT/scripts/record-mirror-refresh.sh"

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  else
    shasum -a 256 "$1" | awk '{ print $1 }'
  fi
}

SOURCE_URL="https://creator.poe.com/docs/test-source"
OTHER_URL="https://creator.poe.com/docs/other-source"
printf '%s\n' "<!-- Source: $SOURCE_URL -->" '# Refreshed guide' > "$FIXTURE_ROOT/docs/test-source.md"
printf '%s\n' '<!-- Source: other fixture -->' '# Other guide' > "$FIXTURE_ROOT/docs/other-source.md"
printf 'test-source\t%s\t2026-06-01\t%s\n' "$SOURCE_URL" '0000000000000000000000000000000000000000000000000000000000000000' > "$FIXTURE_ROOT/docs/sources.tsv"
printf 'other-source\t%s\t2026-06-02\t%s\n' "$OTHER_URL" "$(sha256_file "$FIXTURE_ROOT/docs/other-source.md")" >> "$FIXTURE_ROOT/docs/sources.tsv"
other_row=$(sed -n '2p' "$FIXTURE_ROOT/docs/sources.tsv")

run_recorder() {
  POE_CREATOR_GUIDE_ROOT="$FIXTURE_ROOT" "$FIXTURE_ROOT/scripts/record-mirror-refresh.sh" "$@"
}

output=$(run_recorder test-source 2026-06-13)
expected_hash=$(sha256_file "$FIXTURE_ROOT/docs/test-source.md")
expected_row=$(printf 'test-source\t%s\t2026-06-13\t%s' "$SOURCE_URL" "$expected_hash")
[ "$(sed -n '1p' "$FIXTURE_ROOT/docs/sources.tsv")" = "$expected_row" ] || fail "the selected manifest row was not refreshed exactly"
[ "$(sed -n '2p' "$FIXTURE_ROOT/docs/sources.tsv")" = "$other_row" ] || fail "an unrelated manifest row changed"
printf '%s\n' "$output" | grep -Fq "Recorded reviewed refresh for test-source at 2026-06-13"

manifest_before_symlink=$(cat "$FIXTURE_ROOT/docs/sources.tsv")
printf '%s\n' "<!-- Source: $SOURCE_URL -->" '# External guide' > "$WORK_DIR/external-source.md"
rm -f "$FIXTURE_ROOT/docs/test-source.md"
ln -s "$WORK_DIR/external-source.md" "$FIXTURE_ROOT/docs/test-source.md"
if run_recorder test-source 2026-06-14 >/dev/null 2>&1; then fail "symbolic link mirrors must be rejected"; fi
[ "$(cat "$FIXTURE_ROOT/docs/sources.tsv")" = "$manifest_before_symlink" ] || fail "symlink rejection must not change the manifest"
rm -f "$FIXTURE_ROOT/docs/test-source.md"
printf '%s\n' "<!-- Source: $SOURCE_URL -->" '# Refreshed guide' > "$FIXTURE_ROOT/docs/test-source.md"

cp "$FIXTURE_ROOT/docs/test-source.md" "$WORK_DIR/hard-linked-source.md"
rm "$FIXTURE_ROOT/docs/test-source.md"
ln "$WORK_DIR/hard-linked-source.md" "$FIXTURE_ROOT/docs/test-source.md"
manifest_before_hard_link=$(cat "$FIXTURE_ROOT/docs/sources.tsv")
if run_recorder test-source 2026-06-14 >/dev/null 2>&1; then fail "hard-linked mirrors must be rejected"; fi
[ "$(cat "$FIXTURE_ROOT/docs/sources.tsv")" = "$manifest_before_hard_link" ] || fail "hard-link rejection must not change the manifest"
rm "$FIXTURE_ROOT/docs/test-source.md"
printf '%s\n' "<!-- Source: $SOURCE_URL -->" '# Refreshed guide' > "$FIXTURE_ROOT/docs/test-source.md"

if run_recorder '../escape' 2026-06-13 >/dev/null 2>&1; then fail "invalid slugs must be rejected"; fi
if run_recorder test-source 2026/06/13 >/dev/null 2>&1; then fail "invalid dates must be rejected"; fi
if run_recorder test-source 2026-02-30 >/dev/null 2>&1; then fail "impossible dates must be rejected"; fi
if run_recorder test-source 1900-02-29 >/dev/null 2>&1; then fail "non-leap century dates must be rejected"; fi
run_recorder test-source 2000-02-29 >/dev/null
[ "$(cut -f3 "$FIXTURE_ROOT/docs/sources.tsv" | sed -n '1p')" = "2000-02-29" ] || fail "leap century dates must be accepted"
run_recorder test-source 2024-02-29 >/dev/null
[ "$(cut -f3 "$FIXTURE_ROOT/docs/sources.tsv" | sed -n '1p')" = "2024-02-29" ] || fail "valid leap days must be accepted"
if run_recorder missing-source 2026-06-13 >/dev/null 2>&1; then fail "missing manifest rows must be rejected"; fi
printf '%s\n' '<!-- Source: wrong -->' '# Refreshed guide' > "$FIXTURE_ROOT/docs/test-source.md"
if run_recorder test-source 2026-06-14 >/dev/null 2>&1; then fail "incorrect source attribution must be rejected"; fi
printf '%s\n' "<!-- Source: $SOURCE_URL -->" '# Refreshed guide' > "$FIXTURE_ROOT/docs/test-source.md"
printf 'test-source\t%s\t2026-06-01\t%s\n' "$SOURCE_URL" "$expected_hash" >> "$FIXTURE_ROOT/docs/sources.tsv"
if run_recorder test-source 2026-06-14 >/dev/null 2>&1; then fail "duplicate manifest rows must be rejected"; fi

printf '%s\n' 'Mirror refresh recorder tests passed.'
