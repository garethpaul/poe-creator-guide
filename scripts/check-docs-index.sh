#!/usr/bin/env sh
set -eu

missing=0
count=0
link_count=0
redirect_count=0
plan_count=0
source_attribution_count=0
index_source_pair_count=0
llms_url_plan="docs/plans/2026-06-09-llms-url-deduplication.md"
index_source_pair_plan="docs/plans/2026-06-09-index-source-pair-validation.md"
index_source_url_plan="docs/plans/2026-06-09-index-source-url-validation.md"

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
  source_comment="<!-- Source: $source_url -->"
  local_url="/docs/$slug"

  source_matches=$(grep -Fxc "$source_comment" "$path" || true)
  first_line=$(sed -n '1p' "$path")

  if [ "$source_matches" -ne 1 ]; then
    fail "$path must contain exactly one source attribution comment: $source_comment"
  elif [ "$first_line" != "$source_comment" ]; then
    fail "$path source attribution must be the first line: $source_comment"
  else
    source_attribution_count=$((source_attribution_count + 1))
  fi

  if ! grep -Fq "$source_url" llms.txt; then
    fail "llms.txt missing source URL for $path: $source_url"
  fi

  if ! grep -Fq "($local_url)" index.md && ! grep -Fq "($local_url.html)" index.md; then
    fail "index.md missing local link for $path: $local_url"
  fi

  if ! grep -Fq "$source_url" index.md; then
    fail "index.md missing source URL for $path: $source_url"
  fi

  if ! grep -Fq "]($local_url) ([source]($source_url))" index.md &&
     ! grep -Fq "]($local_url.html) ([source]($source_url))" index.md; then
    fail "index.md missing paired local/source link for $path: $local_url -> $source_url"
  else
    index_source_pair_count=$((index_source_pair_count + 1))
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

if [ ! -f "$llms_url_plan" ]; then
  fail "$llms_url_plan is missing"
fi

if [ ! -f "$index_source_pair_plan" ]; then
  fail "$index_source_pair_plan is missing"
fi

if [ ! -f "$index_source_url_plan" ]; then
  fail "$index_source_url_plan is missing"
fi

urls=$(grep -Eo 'https://creator\.poe\.com/docs/[A-Za-z0-9._/-]+' llms.txt | sort -u || true)
for url in $urls; do
  slug=${url##*/}
  path="docs/$slug.md"

  if [ ! -f "$path" ]; then
    fail "llms.txt references $url but $path is missing"
  fi
done

index_source_urls=$(grep -Eo 'https://creator\.poe\.com/docs/[A-Za-z0-9._/-]+' index.md | sort -u || true)
for url in $index_source_urls; do
  slug=${url##*/}
  path="docs/$slug.md"

  if [ ! -f "$path" ]; then
    fail "index.md references $url but $path is missing"
  fi
done

duplicate_urls=$(
  grep -Eo 'https://creator\.poe\.com/docs/[A-Za-z0-9._/-]+' llms.txt |
    sort |
    uniq -d || true
)

if [ -n "$duplicate_urls" ]; then
  old_ifs=$IFS
  IFS='
'
  for url in $duplicate_urls; do
    fail "llms.txt duplicate source URL: $url"
  done
  IFS=$old_ifs
fi

duplicate_titles=$(
  grep -E '^- \[[^]]+\]\(https://creator\.poe\.com/docs/[A-Za-z0-9._/-]+\)' llms.txt |
    sed 's/^- \[\([^]]*\)\].*/\1/' |
    sort |
    uniq -d || true
)

if [ -n "$duplicate_titles" ]; then
  old_ifs=$IFS
  IFS='
'
  for title in $duplicate_titles; do
    fail "llms.txt duplicate doc title: $title"
  done
  IFS=$old_ifs
fi

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

if [ ! -f index.html ]; then
  fail "index.html is missing"
else
  html_refs=$(grep -Eo '/docs/[A-Za-z0-9._/-]+(\.html)?(#[A-Za-z0-9._~:%/-]+)?' index.html || true)
  if [ -z "$html_refs" ]; then
    fail "index.html must link to at least one local docs page"
  fi

  for ref in $html_refs; do
    slug=${ref#/docs/}
    slug=${slug%%#*}
    slug=${slug%.html}
    path="docs/$slug.md"
    redirect_count=$((redirect_count + 1))

    if [ ! -f "$path" ]; then
      fail "index.html references missing redirect doc: $ref ($path)"
    fi
  done
fi

if [ "$missing" -ne 0 ]; then
  exit 1
fi

printf 'Docs index check passed for %s mirrored pages, %s source attributions, %s paired index source links, %s unique llms source URLs, %s index source URLs, %s local doc links, %s HTML redirect links, and %s docs plans.\n' "$count" "$source_attribution_count" "$index_source_pair_count" "$(printf '%s\n' "$urls" | sed '/^$/d' | wc -l | tr -d ' ')" "$(printf '%s\n' "$index_source_urls" | sed '/^$/d' | wc -l | tr -d ' ')" "$link_count" "$redirect_count" "$plan_count"
