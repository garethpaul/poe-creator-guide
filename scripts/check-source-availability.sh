#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MANIFEST="$ROOT_DIR/docs/sources.tsv"

if ! command -v curl >/dev/null 2>&1; then
  printf '%s\n' "curl is required for the opt-in live source audit." >&2
  exit 1
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

tab=$(printf '\t')
while IFS="$tab" read -r slug source_url verified_at content_sha256; do
  [ -n "$slug" ] || continue
  if ! printf '%s\n' "$content_sha256" | grep -Eq '^[0-9a-f]{64}$'; then
    printf '%s\n' "$slug has an invalid SHA-256 fingerprint: $content_sha256" >&2
    exit 1
  fi
  if ! actual_sha256=$(sha256_file "$ROOT_DIR/docs/$slug.md"); then
    printf '%s\n' "sha256sum or shasum is required to verify mirrored content fingerprints." >&2
    exit 1
  fi
  if [ "$actual_sha256" != "$content_sha256" ]; then
    printf '%s\n' "$slug mirror fingerprint mismatch: expected $content_sha256, got $actual_sha256" >&2
    exit 1
  fi
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
  if ! printf '%s\n' "$verified_at" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    printf '%s\n' "$slug has an invalid verification date: $verified_at" >&2
    exit 1
  fi
  checked=$((checked + 1))
done < "$MANIFEST"

printf '%s\n' "Live source audit passed for $checked canonical Poe pages."
