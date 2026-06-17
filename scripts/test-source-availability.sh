#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/poe-source-audit-test.XXXXXX")
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

FIXTURE_ROOT="$WORK_DIR/repository"
FAKE_BIN="$WORK_DIR/bin"
FAKE_LOG="$WORK_DIR/curl-args"
AUDIT_TMP="$WORK_DIR/tmp"
SOURCE_URL="https://creator.poe.com/docs/test-source"

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

assert_argument_pair() {
  option=$1
  value=$2
  if ! awk -v option="$option" -v value="$value" '
    previous == option && $0 == value { found = 1 }
    { previous = $0 }
    END { exit !found }
  ' "$FAKE_LOG"; then
    fail "curl arguments must contain: $option $value"
  fi
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
  else
    fail "sha256sum or shasum is required to test mirrored content fingerprints."
  fi
}

mkdir -p "$FIXTURE_ROOT/docs" "$FIXTURE_ROOT/scripts" "$FAKE_BIN" "$AUDIT_TMP"
cp "$ROOT_DIR/scripts/check-source-availability.sh" "$FIXTURE_ROOT/scripts/"
cp "$ROOT_DIR/scripts/iso-date.sh" "$FIXTURE_ROOT/scripts/"
chmod +x "$FIXTURE_ROOT/scripts/check-source-availability.sh"
printf '%s\n' '<!-- Source: test fixture -->' '# Test source' > "$FIXTURE_ROOT/docs/test-source.md"
content_sha256=$(sha256_file "$FIXTURE_ROOT/docs/test-source.md")
printf 'test-source\t%s\t2026-06-13\t%s\n' "$SOURCE_URL" "$content_sha256" > "$FIXTURE_ROOT/docs/sources.tsv"

cat > "$FAKE_BIN/curl" <<'EOF'
#!/usr/bin/env sh
set -eu

: "${FAKE_CURL_LOG:?}"
: "${FAKE_CURL_MODE:?}"
printf '%s\n' "$@" > "$FAKE_CURL_LOG"

last_argument=
for argument do
  last_argument=$argument
done

case "$FAKE_CURL_MODE" in
  success) printf '200\t%s' "$last_argument" ;;
  http_error) printf '503\t%s' "$last_argument" ;;
  redirect) printf '200\t%s/' "$last_argument" ;;
  transport_error)
    printf '%s\n' 'fake curl transport failure' >&2
    exit 7
    ;;
  *) exit 64 ;;
esac
EOF
chmod +x "$FAKE_BIN/curl"

run_audit() {
  FAKE_CURL_MODE=$1 FAKE_CURL_LOG="$FAKE_LOG" TMPDIR="$AUDIT_TMP" PATH="$FAKE_BIN:$PATH" \
    "$FIXTURE_ROOT/scripts/check-source-availability.sh" 2>&1
}

write_valid_manifest() {
  verified_at=${1:-2026-06-13}
  printf 'test-source\t%s\t%s\t%s\n' "$SOURCE_URL" "$verified_at" "$content_sha256" > "$FIXTURE_ROOT/docs/sources.tsv"
}

assert_preflight_rejected() {
  expected=$1
  description=$2
  : > "$FAKE_LOG"
  if output=$(run_audit success); then
    fail "$description"
  fi
  assert_contains "$output" "$expected"
  if [ -s "$FAKE_LOG" ]; then
    fail "$description before invoking curl"
  fi
}

output=$(run_audit success)
assert_contains "$output" "Live source audit passed for 1 canonical Poe pages."
for required_argument in --location --silent --show-error --output --write-out; do
  if ! grep -Fxq -- "$required_argument" "$FAKE_LOG"; then
    fail "curl arguments must contain: $required_argument"
  fi
done
assert_argument_pair --max-time 20
assert_argument_pair --retry 2
if [ "$(tail -n 1 "$FAKE_LOG")" != "$SOURCE_URL" ]; then
  fail "the canonical source URL must be the final curl argument"
fi

if output=$(run_audit http_error); then
  fail "the live audit must reject non-200 source responses"
fi
assert_contains "$output" "test-source source returned HTTP 503: $SOURCE_URL"

if output=$(run_audit redirect); then
  fail "the live audit must reject canonical source redirects"
fi
assert_contains "$output" "test-source source redirected: $SOURCE_URL -> $SOURCE_URL/"

if output=$(run_audit transport_error); then
  fail "the live audit must reject curl transport failures"
fi
assert_contains "$output" "fake curl transport failure"

: > "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "source manifest must contain at least one row" \
  "the live audit must reject an empty manifest"

printf 'test-source\t%s\t2026-06-13\n' "$SOURCE_URL" > "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "exactly four non-empty tab-separated fields" \
  "the live audit must reject malformed manifest rows"

printf 'test-source\t%s\t2026-06-13\t%s\textra\n' "$SOURCE_URL" "$content_sha256" > "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "exactly four non-empty tab-separated fields" \
  "the live audit must reject extra manifest fields"

printf 'test-source\t\t2026-06-13\t%s\n' "$content_sha256" > "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "exactly four non-empty tab-separated fields" \
  "the live audit must reject empty manifest fields"

printf '../escape\t%s\t2026-06-13\t%s\n' "$SOURCE_URL" "$content_sha256" > "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "source manifest has an invalid slug: ../escape" \
  "the live audit must reject traversal-shaped slugs"

printf 'test-source\thttps://example.com/docs/test-source\t2026-06-13\t%s\n' "$content_sha256" > "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "source manifest has a non-canonical source URL" \
  "the live audit must reject non-canonical source URLs"

printf 'missing-source\thttps://creator.poe.com/docs/missing-source\t2026-06-13\t%s\n' "$content_sha256" > "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "source manifest references missing mirror: docs/missing-source.md" \
  "the live audit must reject missing mirrors"

printf '%s\n' '<!-- Source: external fixture -->' '# External source' > "$WORK_DIR/external-source.md"
external_sha256=$(sha256_file "$WORK_DIR/external-source.md")
rm -f "$FIXTURE_ROOT/docs/test-source.md"
ln -s "$WORK_DIR/external-source.md" "$FIXTURE_ROOT/docs/test-source.md"
printf 'test-source\t%s\t2026-06-13\t%s\n' "$SOURCE_URL" "$external_sha256" > "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "source manifest references symbolic link mirror: docs/test-source.md" \
  "the live audit must reject symbolic link mirrors"
rm -f "$FIXTURE_ROOT/docs/test-source.md"
printf '%s\n' '<!-- Source: test fixture -->' '# Test source' > "$FIXTURE_ROOT/docs/test-source.md"

printf 'test-source\t%s\t2026-06-13\tinvalid\n' "$SOURCE_URL" > "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "test-source has an invalid SHA-256 fingerprint: invalid" \
  "the live audit must reject malformed fingerprints"

write_valid_manifest
printf 'test-source\thttps://creator.poe.com/docs/other-source\t2026-06-13\t%s\n' "$content_sha256" >> "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "source manifest contains duplicate local slugs" \
  "the live audit must reject duplicate slugs"

write_valid_manifest
printf 'other-source\t%s\t2026-06-13\t%s\n' "$SOURCE_URL" "$content_sha256" >> "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "source manifest contains duplicate canonical URLs" \
  "the live audit must reject duplicate canonical URLs"

write_valid_manifest
printf '../later-escape\thttps://creator.poe.com/docs/later-escape\t2026-06-13\t%s\n' "$content_sha256" >> "$FIXTURE_ROOT/docs/sources.tsv"
assert_preflight_rejected "source manifest has an invalid slug: ../later-escape" \
  "the live audit must validate every manifest row before invoking curl"

write_valid_manifest 2026-02-30
assert_preflight_rejected "test-source has an invalid verification date: 2026-02-30" \
  "the live audit must reject impossible calendar dates; the live audit must validate dates before invoking curl"

write_valid_manifest 2024-02-29
output=$(run_audit success)
assert_contains "$output" "Live source audit passed for 1 canonical Poe pages."

: > "$FAKE_LOG"
printf '%s\n' 'changed mirror' >> "$FIXTURE_ROOT/docs/test-source.md"
if output=$(run_audit success); then
  fail "the live audit must reject a changed mirror fingerprint"
fi
assert_contains "$output" "test-source mirror fingerprint mismatch"
if [ -s "$FAKE_LOG" ]; then
  fail "the live audit must verify the mirror fingerprint before invoking curl"
fi
if find "$AUDIT_TMP" -type f | grep -q .; then
  fail "temporary manifest snapshots must be removed"
fi

printf '%s\n' "Live source audit contract tests passed."
