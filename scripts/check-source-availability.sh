#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MANIFEST="$ROOT_DIR/docs/sources.tsv"
. "$ROOT_DIR/scripts/iso-date.sh"

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

if ! command -v curl >/dev/null 2>&1; then
  fail "curl is required for the opt-in live source audit."
fi

checked=0

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
  else
    return 1
  fi
}

[ -f "$MANIFEST" ] || fail "source manifest is missing: $MANIFEST"
[ -s "$MANIFEST" ] || fail "source manifest must contain at least one row"
AUDIT_MANIFEST=$(mktemp "${TMPDIR:-/tmp}/poe-source-audit.XXXXXX")
trap 'rm -f "$AUDIT_MANIFEST"' EXIT HUP INT TERM
cp "$MANIFEST" "$AUDIT_MANIFEST"

malformed_rows=$(awk -F '\t' '
  NF != 4 || $1 == "" || $2 == "" || $3 == "" || $4 == "" { print NR }
' "$AUDIT_MANIFEST")
if [ -n "$malformed_rows" ]; then
  fail "source manifest must contain exactly four non-empty tab-separated fields per row: $malformed_rows"
fi

duplicate_slugs=$(cut -f1 "$AUDIT_MANIFEST" | sort | uniq -d || true)
[ -z "$duplicate_slugs" ] || fail "source manifest contains duplicate local slugs: $duplicate_slugs"
duplicate_urls=$(cut -f2 "$AUDIT_MANIFEST" | sort | uniq -d || true)
[ -z "$duplicate_urls" ] || fail "source manifest contains duplicate canonical URLs: $duplicate_urls"

tab=$(printf '\t')
while IFS="$tab" read -r slug source_url verified_at content_sha256; do
  case "$slug" in
    *[!A-Za-z0-9._-]*) fail "source manifest has an invalid slug: $slug" ;;
  esac
  case "$source_url" in
    https://creator.poe.com/docs/*) ;;
    *) fail "source manifest has a non-canonical source URL for $slug: $source_url" ;;
  esac
  mirror="$ROOT_DIR/docs/$slug.md"
  [ ! -L "$mirror" ] || fail "source manifest references symbolic link mirror: docs/$slug.md"
  [ -f "$mirror" ] || fail "source manifest references missing mirror: docs/$slug.md"
  if ! printf '%s\n' "$content_sha256" | grep -Eq '^[0-9a-f]{64}$'; then
    fail "$slug has an invalid SHA-256 fingerprint: $content_sha256"
  fi
  if ! actual_sha256=$(sha256_file "$mirror"); then
    fail "sha256sum or shasum is required to verify mirrored content fingerprints."
  fi
  if [ "$actual_sha256" != "$content_sha256" ]; then
    fail "$slug mirror fingerprint mismatch: expected $content_sha256, got $actual_sha256"
  fi
  if ! is_valid_iso_date "$verified_at"; then
    fail "$slug has an invalid verification date: $verified_at"
  fi
done < "$AUDIT_MANIFEST"

while IFS="$tab" read -r slug source_url verified_at content_sha256; do
  result=$(curl \
    --location \
    --silent \
    --show-error \
    --max-time 20 \
    --retry 2 \
    --output /dev/null \
    --write-out '%{http_code}\t%{url_effective}' \
    "$source_url")
  status=${result%%"$tab"*}
  final_url=${result#*"$tab"}

  if [ "$status" != "200" ]; then
    printf '%s\n' "$slug source returned HTTP $status: $source_url" >&2
    exit 1
  fi
  if [ "$final_url" != "$source_url" ]; then
    printf '%s\n' "$slug source redirected: $source_url -> $final_url" >&2
    exit 1
  fi
  checked=$((checked + 1))
done < "$AUDIT_MANIFEST"

printf '%s\n' "Live source audit passed for $checked canonical Poe pages."
