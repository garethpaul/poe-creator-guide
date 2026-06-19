#!/usr/bin/env sh
set -eu

ROOT_DIR=${POE_CREATOR_GUIDE_ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
MANIFEST="$ROOT_DIR/docs/sources.tsv"
. "$ROOT_DIR/scripts/iso-date.sh"

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
  else
    fail "sha256sum or shasum is required to record a mirror refresh"
  fi
}

if [ "$#" -ne 2 ]; then
  fail "usage: scripts/record-mirror-refresh.sh <slug> <YYYY-MM-DD>"
fi

slug=$1
verified_at=$2
case "$slug" in
  ''|*[!A-Za-z0-9._-]*) fail "invalid mirror slug: $slug" ;;
esac
if ! is_valid_iso_date "$verified_at"; then
  fail "invalid verification date: $verified_at"
fi

[ -f "$MANIFEST" ] || fail "source manifest is missing: $MANIFEST"
mirror="$ROOT_DIR/docs/$slug.md"
[ -f "$mirror" ] || fail "mirror is missing: docs/$slug.md"

row_count=$(awk -F '\t' -v slug="$slug" '$1 == slug { count += 1 } END { print count + 0 }' "$MANIFEST")
[ "$row_count" -eq 1 ] || fail "source manifest must contain exactly one row for: $slug"
source_url=$(awk -F '\t' -v slug="$slug" '$1 == slug { print $2 }' "$MANIFEST")
case "$source_url" in
  https://creator.poe.com/docs/*) ;;
  *) fail "source manifest has an invalid canonical URL for: $slug" ;;
esac

expected_comment="<!-- Source: $source_url -->"
first_line=$(sed -n '1p' "$mirror")
[ "$first_line" = "$expected_comment" ] ||
  fail "mirror must keep the canonical source comment on its first line: $expected_comment"

content_sha256=$(sha256_file "$mirror")
temporary=$(mktemp "$ROOT_DIR/docs/.sources.tsv.XXXXXX")
trap 'rm -f "$temporary"' EXIT HUP INT TERM

awk -F '\t' -v OFS='\t' -v slug="$slug" -v verified_at="$verified_at" -v content_sha256="$content_sha256" '
  $1 == slug { $3 = verified_at; $4 = content_sha256 }
  { print }
' "$MANIFEST" > "$temporary"

chmod 0644 "$temporary"
mv "$temporary" "$MANIFEST"
trap - EXIT HUP INT TERM
printf 'Recorded reviewed refresh for %s at %s with SHA-256 %s.\n' "$slug" "$verified_at" "$content_sha256"
