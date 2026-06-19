#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/poe-source-audit-test.XXXXXX")
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

FIXTURE_ROOT="$WORK_DIR/repository"
FAKE_BIN="$WORK_DIR/bin"
FAKE_LOG="$WORK_DIR/curl-args"
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

mkdir -p "$FIXTURE_ROOT/docs" "$FIXTURE_ROOT/scripts" "$FAKE_BIN"
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
  FAKE_CURL_MODE=$1 FAKE_CURL_LOG="$FAKE_LOG" PATH="$FAKE_BIN:$PATH" \
    "$FIXTURE_ROOT/scripts/check-source-availability.sh" 2>&1
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

: > "$FAKE_LOG"
sed 's/2026-06-13/2026-02-30/' "$FIXTURE_ROOT/docs/sources.tsv" > "$FIXTURE_ROOT/docs/sources.tsv.tmp"
mv "$FIXTURE_ROOT/docs/sources.tsv.tmp" "$FIXTURE_ROOT/docs/sources.tsv"
if output=$(run_audit success); then
  fail "the live audit must reject impossible calendar dates"
fi
assert_contains "$output" "test-source has an invalid verification date: 2026-02-30"
if [ -s "$FAKE_LOG" ]; then
  fail "the live audit must validate dates before invoking curl"
fi
sed 's/2026-02-30/2024-02-29/' "$FIXTURE_ROOT/docs/sources.tsv" > "$FIXTURE_ROOT/docs/sources.tsv.tmp"
mv "$FIXTURE_ROOT/docs/sources.tsv.tmp" "$FIXTURE_ROOT/docs/sources.tsv"
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

printf '%s\n' "Live source audit contract tests passed."
