#!/usr/bin/env sh
set -eu

missing=0
count=0

fail() {
  printf '%s\n' "$1" >&2
  missing=1
}

for path in docs/*.md; do
  [ -f "$path" ] || continue

  slug=${path#docs/}
  slug=${slug%.md}
  count=$((count + 1))

  source_url="https://creator.poe.com/docs/$slug"
  local_url="/docs/$slug"

  if ! grep -Fq "$source_url" llms.txt; then
    fail "llms.txt missing source URL for $path: $source_url"
  fi

  if ! grep -Fq "($local_url)" index.md && ! grep -Fq "($local_url.html)" index.md; then
    fail "index.md missing local link for $path: $local_url"
  fi
done

if [ "$count" -eq 0 ]; then
  fail "no Markdown documents found under docs/"
fi

urls=$(grep -Eo 'https://creator\.poe\.com/docs/[A-Za-z0-9._/-]+' llms.txt | sort -u || true)
for url in $urls; do
  slug=${url##*/}
  path="docs/$slug.md"

  if [ ! -f "$path" ]; then
    fail "llms.txt references $url but $path is missing"
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

printf 'Docs index check passed for %s mirrored pages.\n' "$count"
