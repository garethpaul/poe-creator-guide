#!/usr/bin/env sh
set -eu

missing=0
count=0
link_count=0
plan_count=0

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

for plan in docs/plans/*.md; do
  [ -f "$plan" ] || continue
  plan_count=$((plan_count + 1))

  if ! grep -Fqi "status: completed" "$plan"; then
    fail "$plan must record status: completed"
  fi
done

if [ "$plan_count" -eq 0 ]; then
  fail "no completed maintenance plans found under docs/plans/"
fi

urls=$(grep -Eo 'https://creator\.poe\.com/docs/[A-Za-z0-9._/-]+' llms.txt | sort -u || true)
for url in $urls; do
  slug=${url##*/}
  path="docs/$slug.md"

  if [ ! -f "$path" ]; then
    fail "llms.txt references $url but $path is missing"
  fi
done

for file in index.md docs/*.md; do
  [ -f "$file" ] || continue

  links=$(grep -Eo '\(/docs/[A-Za-z0-9._/-]+(\.html)?(#[A-Za-z0-9._~:%/-]+)?\)' "$file" || true)
  for link in $links; do
    ref=${link#(}
    ref=${ref%)}
    slug=${ref#/docs/}
    slug=${slug%%#*}
    slug=${slug%.html}
    path="docs/$slug.md"
    link_count=$((link_count + 1))

    if [ ! -f "$path" ]; then
      fail "$file references missing local doc: $ref ($path)"
    fi
  done
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

printf 'Docs index check passed for %s mirrored pages, %s local doc links, and %s docs plans.\n' "$count" "$link_count" "$plan_count"
