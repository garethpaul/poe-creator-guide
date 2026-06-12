#!/usr/bin/env sh
set -eu

missing=0
count=0
link_count=0
fragment_count=0
redirect_count=0
plan_count=0
source_attribution_count=0
index_source_pair_count=0
llms_url_plan="docs/plans/2026-06-09-llms-url-deduplication.md"
index_source_pair_plan="docs/plans/2026-06-09-index-source-pair-validation.md"
index_source_url_plan="docs/plans/2026-06-09-index-source-url-validation.md"
index_dedup_plan="docs/plans/2026-06-09-index-entry-deduplication.md"
ci_plan="docs/plans/2026-06-10-ci-baseline.md"
hosted_validation_plan="docs/plans/2026-06-10-hosted-docs-validation.md"
fragment_validation_plan="docs/plans/2026-06-10-local-fragment-validation.md"
legacy_local_link_plan="docs/plans/2026-06-12-legacy-local-link-validation.md"
workflow=".github/workflows/check.yml"

fail() {
  printf '%s\n' "$1" >&2
  missing=1
}

heading_anchors() {
  awk '
    /^#{1,6}[[:space:]]+/ {
      heading = $0
      sub(/^#{1,6}[[:space:]]+/, "", heading)
      print heading
    }
    /^[=-]+[[:space:]]*$/ && previous != "" { print previous }
    { previous = $0 }
  ' "$1" |
    sed -E 's/<[^>]*>//g; s/[`*]//g; s/\\//g' |
    tr '[:upper:]' '[:lower:]' |
    sed -E 's/[^a-z0-9 _-]//g; s/[[:space:]]+/-/g; s/-+/-/g; s/^-//; s/-$//'
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

if [ ! -f "$index_dedup_plan" ]; then
  fail "$index_dedup_plan is missing"
fi

if [ ! -f "$ci_plan" ]; then
  fail "$ci_plan is missing"
fi

if ! grep -Fq "Status: Completed" "$ci_plan" ||
   ! grep -Fq "make check" "$ci_plan"; then
  fail "$ci_plan must record completed status and make check verification"
fi
if [ ! -f "$hosted_validation_plan" ]; then
  fail "$hosted_validation_plan is missing"
fi

if [ ! -f "$fragment_validation_plan" ]; then
  fail "$fragment_validation_plan is missing"
fi

if [ ! -f "$legacy_local_link_plan" ]; then
  fail "$legacy_local_link_plan is missing"
fi

if [ ! -f "$workflow" ]; then
  fail "$workflow is missing"
else
  checkout_contract=$(sed -n '/^      - name: Check out repository$/,/^      - name: Validate mirrored documentation$/p' "$workflow" | sed '$d')
  expected_checkout_contract='      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false'
  action_count=$(grep -Ec '^[[:space:]]*(- )?uses:' "$workflow" || true)
  credential_count=$(grep -Fc 'persist-credentials:' "$workflow" || true)
  permissions_count=$(grep -Ec '^permissions:$' "$workflow" || true)

  if [ "$checkout_contract" != "$expected_checkout_contract" ] ||
     [ "$action_count" -ne 1 ] ||
     [ "$credential_count" -ne 1 ] ||
     [ "$permissions_count" -ne 1 ] ||
     grep -Eq '^[[:space:]]+[A-Za-z-]+:[[:space:]]+write[[:space:]]*$' "$workflow" ||
     ! grep -Fxq '  contents: read' "$workflow" ||
     ! grep -Fq 'cancel-in-progress: true' "$workflow" ||
     ! grep -Fq 'runs-on: ubuntu-24.04' "$workflow" ||
     ! grep -Fq 'timeout-minutes: 10' "$workflow" ||
     ! grep -Fq 'workflow_dispatch:' "$workflow" ||
     ! grep -Eq '^[[:space:]]+run: make check$' "$workflow"; then
    fail "$workflow must keep singular pinned credential-free checkout, read-only permissions, manual dispatch, and bounded offline validation"
  fi
fi

for docs_baseline_file in README.md VISION.md SECURITY.md CHANGES.md; do
  if ! grep -Fq "GitHub Actions" "$docs_baseline_file"; then
    fail "$docs_baseline_file must document the GitHub Actions baseline"
  fi
done

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

duplicate_index_source_urls=$(
  grep -Eo 'https://creator\.poe\.com/docs/[A-Za-z0-9._/-]+' index.md |
    sort |
    uniq -d || true
)

if [ -n "$duplicate_index_source_urls" ]; then
  old_ifs=$IFS
  IFS='
'
  for url in $duplicate_index_source_urls; do
    fail "index.md duplicate source URL: $url"
  done
  IFS=$old_ifs
fi

duplicate_index_local_refs=$(
  grep -Eo '\(/docs/[A-Za-z0-9._/-]+(\.html)?(#[A-Za-z0-9._~:%/-]+)?\)' index.md |
    sed 's/^(\(.*\))$/\1/; s/#.*$//; s/\.html$//' |
    sort |
    uniq -d || true
)

if [ -n "$duplicate_index_local_refs" ]; then
  old_ifs=$IFS
  IFS='
'
  for ref in $duplicate_index_local_refs; do
    fail "index.md duplicate local docs link: $ref"
  done
  IFS=$old_ifs
fi

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

legacy_local_links=$(grep -En '\]\((doc:[^ )]+|\.\./[^ )]+\.md(#[^ )]+)?)\)' index.md docs/*.md || true)
if [ -n "$legacy_local_links" ]; then
  old_ifs=$IFS
  IFS='
'
  for match in $legacy_local_links; do
    fail "legacy local documentation link must use /docs/<slug>: $match"
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
    elif [ "$ref" != "${ref#*#}" ]; then
      fragment=${ref#*#}
      fragment_count=$((fragment_count + 1))
      if ! heading_anchors "$path" | grep -Fxq "$fragment"; then
        fail "$file references missing local heading: $ref ($path#$fragment)"
      fi
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

  html_redirect_targets=$(
    printf '%s\n' "$html_refs" |
      sed 's/#.*$//; s/\.html$//' |
      sort -u
  )
  html_redirect_target_count=$(printf '%s\n' "$html_redirect_targets" | sed '/^$/d' | wc -l | tr -d ' ')
  if [ "$html_redirect_target_count" -ne 1 ]; then
    fail "index.html redirect links must point to one mirrored document"
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

printf 'Docs index check passed for %s mirrored pages, %s source attributions, %s paired index source links, %s unique llms source URLs, %s index source URLs, %s local doc links, %s heading fragments, %s HTML redirect links, and %s docs plans.\n' "$count" "$source_attribution_count" "$index_source_pair_count" "$(printf '%s\n' "$urls" | sed '/^$/d' | wc -l | tr -d ' ')" "$(printf '%s\n' "$index_source_urls" | sed '/^$/d' | wc -l | tr -d ' ')" "$link_count" "$fragment_count" "$redirect_count" "$plan_count"
