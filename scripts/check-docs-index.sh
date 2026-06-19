#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"
. scripts/iso-date.sh

missing=0
count=0
link_count=0
fragment_count=0
redirect_count=0
plan_count=0
source_attribution_count=0
index_source_pair_count=0
manifest_count=0
fingerprint_count=0
manifest="docs/sources.tsv"
source_availability_script="scripts/check-source-availability.sh"
source_availability_tests="scripts/test-source-availability.sh"
mirror_refresh_script="scripts/record-mirror-refresh.sh"
mirror_refresh_tests="scripts/test-mirror-refresh.sh"
iso_date_helper="scripts/iso-date.sh"
source_manifest_plan="docs/plans/2026-06-12-canonical-source-manifest.md"
content_fingerprint_plan="docs/plans/2026-06-13-mirrored-content-fingerprints.md"
source_availability_test_plan="docs/plans/2026-06-13-live-source-audit-tests.md"
mirror_refresh_plan="docs/plans/2026-06-13-mirror-refresh-process.md"
location_independent_make_plan="docs/plans/2026-06-14-location-independent-make.md"
calendar_date_plan="docs/plans/2026-06-15-calendar-date-validation.md"
live_audit_boundary_plan="docs/plans/2026-06-17-live-audit-manifest-boundary.md"
makefile="Makefile"
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

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
  else
    return 1
  fi
}

hash_tool_available=1
if ! command -v sha256sum >/dev/null 2>&1 &&
   ! command -v shasum >/dev/null 2>&1; then
  fail "sha256sum or shasum is required to verify mirrored content fingerprints"
  hash_tool_available=0
fi

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

if [ ! -f "$manifest" ]; then
  fail "$manifest is missing"
else
  malformed_manifest_rows=$(awk -F '\t' 'NF != 4 || $1 == "" || $2 == "" || $3 == "" || $4 == "" { print NR }' "$manifest")
  if [ -n "$malformed_manifest_rows" ]; then
    fail "$manifest must contain exactly four non-empty tab-separated fields per row"
  fi

  duplicate_manifest_slugs=$(cut -f1 "$manifest" | sort | uniq -d || true)
  duplicate_manifest_urls=$(cut -f2 "$manifest" | sort | uniq -d || true)
  if [ -n "$duplicate_manifest_slugs" ]; then
    fail "$manifest contains duplicate local slugs: $duplicate_manifest_slugs"
  fi
  if [ -n "$duplicate_manifest_urls" ]; then
    fail "$manifest contains duplicate canonical URLs: $duplicate_manifest_urls"
  fi

  tab=$(printf '\t')
  while IFS="$tab" read -r slug source_url verified_at content_sha256; do
    [ -n "$slug" ] || continue
    manifest_count=$((manifest_count + 1))
    case "$slug" in
      *[!A-Za-z0-9._-]*) fail "$manifest has an invalid slug: $slug" ;;
    esac
    case "$source_url" in
      https://creator.poe.com/docs/*) ;;
      *) fail "$manifest has a non-canonical source URL for $slug: $source_url" ;;
    esac
    if ! is_valid_iso_date "$verified_at"; then
      fail "$manifest has an invalid verification date for $slug: $verified_at"
    fi
    if ! printf '%s\n' "$content_sha256" | grep -Eq '^[0-9a-f]{64}$'; then
      fail "$manifest has an invalid SHA-256 fingerprint for $slug: $content_sha256"
    fi
    if [ ! -f "docs/$slug.md" ]; then
      fail "$manifest references missing mirror: docs/$slug.md"
      continue
    fi
    if [ "$hash_tool_available" -eq 0 ]; then
      continue
    fi
    actual_sha256=$(sha256_file "docs/$slug.md")
    if [ "$actual_sha256" != "$content_sha256" ]; then
      fail "$manifest fingerprint mismatch for docs/$slug.md: expected $content_sha256, got $actual_sha256"
    else
      fingerprint_count=$((fingerprint_count + 1))
    fi
  done < "$manifest"
fi

if [ ! -x "$source_availability_script" ]; then
  fail "$source_availability_script must exist and be executable"
fi

if [ ! -f "$iso_date_helper" ]; then
  fail "$iso_date_helper is missing"
else
  for date_contract in \
    'is_valid_iso_date()' \
    'year % 400 == 0' \
    'year % 4 == 0 && year % 100 != 0' \
    'day >= 1 && day <= days'; do
    if ! grep -Fq "$date_contract" "$iso_date_helper"; then
      fail "$iso_date_helper must preserve calendar validation: $date_contract"
    fi
  done
fi

for date_consumer in "$source_availability_script" "$mirror_refresh_script" scripts/check-docs-index.sh; do
  if ! grep -Fq 'is_valid_iso_date' "$date_consumer"; then
    fail "$date_consumer must use the shared calendar-date validator"
  fi
done

manifest_date_calls=$(sed -n '1,/if \[ ! -x "$source_availability_script"/p' scripts/check-docs-index.sh |
  grep -Fc 'if ! is_valid_iso_date "$verified_at"; then' || true)
if [ "$manifest_date_calls" -ne 1 ]; then
  fail "scripts/check-docs-index.sh must validate each manifest date exactly once"
fi

date_line=$(grep -nF 'if ! is_valid_iso_date "$verified_at"; then' "$source_availability_script" | cut -d: -f1)
curl_line=$(grep -nF 'result=$(curl \' "$source_availability_script" | cut -d: -f1)
if [ -z "$date_line" ] || [ -z "$curl_line" ] || [ "$date_line" -ge "$curl_line" ]; then
  fail "$source_availability_script must validate dates before invoking curl"
fi

preflight_read_count=$(sed -n '1,/result=$(curl \\/p' "$source_availability_script" |
  grep -Fc 'while IFS="$tab" read -r slug source_url verified_at content_sha256; do' || true)
if [ "$preflight_read_count" -ne 2 ]; then
  fail "$source_availability_script must complete a full manifest preflight before invoking curl"
fi
snapshot_read_count=$(grep -Fc 'done < "$AUDIT_MANIFEST"' "$source_availability_script" || true)
if [ "$snapshot_read_count" -ne 2 ]; then
  fail "$source_availability_script must use the validated manifest snapshot for both phases"
fi

for preflight_contract in \
  'AUDIT_MANIFEST=$(mktemp' \
  'cp "$MANIFEST" "$AUDIT_MANIFEST"' \
  'source manifest must contain at least one row' \
  'exactly four non-empty tab-separated fields' \
  'source manifest contains duplicate local slugs' \
  'source manifest contains duplicate canonical URLs' \
  'source manifest has an invalid slug' \
  'source manifest has a non-canonical source URL' \
  'source manifest references missing mirror'; do
  if ! grep -Fq "$preflight_contract" "$source_availability_script"; then
    fail "$source_availability_script must preserve manifest preflight validation: $preflight_contract"
  fi
done

for fixture_contract in \
  'the live audit must reject impossible calendar dates' \
  'the live audit must validate dates before invoking curl' \
  '2024-02-29'; do
  if ! grep -Fq "$fixture_contract" "$source_availability_tests"; then
    fail "$source_availability_tests must preserve calendar-date coverage: $fixture_contract"
  fi
done

for fixture_contract in \
  'impossible dates must be rejected' \
  'non-leap century dates must be rejected' \
  'leap century dates must be accepted' \
  'valid leap days must be accepted' \
  '2000-02-29' \
  '2024-02-29'; do
  if ! grep -Fq "$fixture_contract" "$mirror_refresh_tests"; then
    fail "$mirror_refresh_tests must preserve calendar-date coverage: $fixture_contract"
  fi
done

if [ ! -f "$calendar_date_plan" ]; then
  fail "$calendar_date_plan is missing"
else
  for evidence in \
    'Status: Completed' \
    '## Verification' \
    'hostile mutations' \
    'make check'; do
    if ! grep -Fqi "$evidence" "$calendar_date_plan"; then
      fail "$calendar_date_plan must preserve completed evidence: $evidence"
    fi
  done
fi

for live_contract in \
  '--location' \
  "status" \
  'final_url' \
  'read -r slug source_url verified_at content_sha256' \
  'sha256_file' \
  'Live source audit passed'; do
  if ! grep -Fq -- "$live_contract" "$source_availability_script"; then
    fail "$source_availability_script must preserve the live source contract: $live_contract"
  fi
done

if ! grep -Fq 'check-sources:' "$makefile" ||
   ! grep -Fq 'scripts/check-source-availability.sh' "$makefile"; then
  fail "$makefile must expose the opt-in check-sources command"
fi

if [ ! -x "$source_availability_tests" ]; then
  fail "$source_availability_tests must exist and be executable"
else
  for test_contract in \
    'FAKE_CURL_MODE' \
    'assert_argument_pair --max-time 20' \
    'assert_argument_pair --retry 2' \
    'run_audit http_error' \
    'run_audit redirect' \
    'run_audit transport_error' \
    'mirror fingerprint mismatch' \
    'verify the mirror fingerprint before invoking curl' \
    'reject an empty manifest' \
    'reject malformed manifest rows' \
    'reject extra manifest fields' \
    'reject empty manifest fields' \
    'reject traversal-shaped slugs' \
    'reject non-canonical source URLs' \
    'reject missing mirrors' \
    'reject malformed fingerprints' \
    'reject duplicate slugs' \
    'reject duplicate canonical URLs' \
    'validate every manifest row before invoking curl' \
    'temporary manifest snapshots must be removed'; do
    if ! grep -Fq -- "$test_contract" "$source_availability_tests"; then
      fail "$source_availability_tests must preserve the offline live-audit contract: $test_contract"
    fi
  done
fi

if [ ! -f "$live_audit_boundary_plan" ]; then
  fail "$live_audit_boundary_plan is missing"
else
  for evidence in \
    'Status: Completed' \
    '## Verification' \
    'hostile mutations' \
    'make check'; do
    if ! grep -Fqi "$evidence" "$live_audit_boundary_plan"; then
      fail "$live_audit_boundary_plan must preserve completed evidence: $evidence"
    fi
  done
fi

if ! grep -Fq 'scripts/test-source-availability.sh' "$makefile"; then
  fail "$makefile test gate must execute the offline live source audit tests"
fi

if [ ! -f "$source_availability_test_plan" ]; then
  fail "$source_availability_test_plan is missing"
else
  for evidence in \
    'status: completed' \
    'sh -n' \
    'dash -n' \
    'make check' \
    'hostile mutations rejected' \
    'git diff --check' \
    'secret, captured-prompt, generated-artifact, source-manifest, and dependency scan'; do
    if ! grep -Fq "$evidence" "$source_availability_test_plan"; then
      fail "$source_availability_test_plan must preserve completed evidence: $evidence"
    fi
  done
fi

for source_documentation in README.md VISION.md SECURITY.md CHANGES.md; do
  if ! grep -Fq 'docs/sources.tsv' "$source_documentation"; then
    fail "$source_documentation must document docs/sources.tsv"
  fi
done

for fingerprint_documentation in README.md VISION.md SECURITY.md CHANGES.md; do
  if ! grep -Fq 'mirrored content fingerprints' "$fingerprint_documentation"; then
    fail "$fingerprint_documentation must document mirrored content fingerprints"
  fi
done

for source_test_documentation in README.md VISION.md SECURITY.md CHANGES.md; do
  if ! grep -Fq 'network-free live source audit tests' "$source_test_documentation"; then
    fail "$source_test_documentation must document the network-free live source audit tests"
  fi
done

if [ ! -f "$source_manifest_plan" ]; then
  fail "$source_manifest_plan is missing"
fi

if [ ! -f "$content_fingerprint_plan" ]; then
  fail "$content_fingerprint_plan is missing"
else
  for evidence in \
    'status: completed' \
    'sh -n' \
    'dash -n' \
    'make check' \
    'hostile mutations rejected' \
    'mirrored page paths had no diff' \
    'git diff --check' \
    'secret, captured-prompt, generated-artifact, URL/date, and dependency-drift scan'; do
    if ! grep -Fq "$evidence" "$content_fingerprint_plan"; then
      fail "$content_fingerprint_plan must preserve completed evidence: $evidence"
    fi
  done
fi

for required_path in "$mirror_refresh_script" "$mirror_refresh_tests" "$mirror_refresh_plan"; do
  if [ ! -f "$required_path" ]; then
    fail "$required_path is missing"
  fi
done

if [ -f "$mirror_refresh_script" ]; then
  for contract in \
    'POE_CREATOR_GUIDE_ROOT' \
    'invalid mirror slug' \
    'invalid verification date' \
    'exactly one row' \
    'canonical source comment on its first line' \
    'sha256_file "$mirror"' \
    'mktemp "$ROOT_DIR/docs/.sources.tsv.XXXXXX"' \
    'chmod 0644 "$temporary"' \
    'mv "$temporary" "$MANIFEST"'; do
    if ! grep -Fq "$contract" "$mirror_refresh_script"; then
      fail "$mirror_refresh_script must preserve the refresh contract: $contract"
    fi
  done
fi

if [ -f "$mirror_refresh_tests" ]; then
  for contract in \
    'the selected manifest row was not refreshed exactly' \
    'an unrelated manifest row changed' \
    'invalid slugs must be rejected' \
    'invalid dates must be rejected' \
    'missing manifest rows must be rejected' \
    'incorrect source attribution must be rejected' \
    'duplicate manifest rows must be rejected'; do
    if ! grep -Fq "$contract" "$mirror_refresh_tests"; then
      fail "$mirror_refresh_tests must preserve the fixture: $contract"
    fi
  done
fi

for contract in \
  '.PHONY: check check-sources record-refresh lint test build verify' \
  'record-refresh:' \
  'scripts/record-mirror-refresh.sh "$(SLUG)" "$(VERIFIED_AT)"' \
  'scripts/test-mirror-refresh.sh'; do
  if ! grep -Fq "$contract" "$makefile"; then
    fail "$makefile must preserve the refresh target contract: $contract"
  fi
done

for contract in \
  'override REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))' \
  'cd "$(REPO_ROOT)" && scripts/check-source-availability.sh' \
  'cd "$(REPO_ROOT)" && scripts/record-mirror-refresh.sh "$(SLUG)" "$(VERIFIED_AT)"' \
  'cd "$(REPO_ROOT)" && scripts/check-docs-index.sh' \
  'cd "$(REPO_ROOT)" && scripts/test-source-availability.sh' \
  'cd "$(REPO_ROOT)" && scripts/test-mirror-refresh.sh'; do
  if ! grep -Fq "$contract" "$makefile"; then
    fail "$makefile must remain caller-directory independent: $contract"
  fi
done

if [ ! -f "$location_independent_make_plan" ]; then
  fail "$location_independent_make_plan is missing"
else
  for evidence in \
    'status: completed' \
    'absolute Makefile path from /tmp' \
    'REPO_ROOT=/tmp' \
    'deterministic fake curl' \
    'six isolated hostile mutations' \
    'git diff --check' \
    'credential-pattern'; do
    if ! grep -Fq "$evidence" "$location_independent_make_plan"; then
      fail "$location_independent_make_plan must preserve completed evidence: $evidence"
    fi
  done
fi

for document in README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fiq 'mirror refresh' "$document"; then
    fail "$document must document the mirror refresh process"
  fi
done

if [ -f "$mirror_refresh_plan" ]; then
  for evidence in \
    'status: completed' \
    'scripts/test-mirror-refresh.sh' \
    'make check' \
    'hostile mutations' \
    'git diff --check'; do
    if ! grep -Fq "$evidence" "$mirror_refresh_plan"; then
      fail "$mirror_refresh_plan must preserve completed evidence: $evidence"
    fi
  done
fi

for path in docs/*.md; do
  [ -f "$path" ] || continue

  slug=${path#docs/}
  slug=${slug%.md}
  count=$((count + 1))

  source_url=$(awk -F '\t' -v slug="$slug" '$1 == slug { print $2 }' "$manifest")
  if [ -z "$source_url" ]; then
    fail "$manifest is missing source metadata for $path"
    continue
  fi
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

if [ "$manifest_count" -ne "$count" ]; then
  fail "$manifest must contain exactly one row for each mirrored page: $manifest_count rows for $count pages"
fi

for plan in docs/plans/*.md; do
  [ -f "$plan" ] || continue
  plan_count=$((plan_count + 1))

  if [ "$(grep -Eic '^status: completed$' "$plan")" -ne 1 ]; then
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
  if ! awk -F '\t' -v url="$url" '$2 == url { found = 1 } END { exit !found }' "$manifest"; then
    fail "llms.txt references a source URL absent from $manifest: $url"
  fi
done

index_source_urls=$(grep -Eo 'https://creator\.poe\.com/docs/[A-Za-z0-9._/-]+' index.md | sort -u || true)
for url in $index_source_urls; do
  if ! awk -F '\t' -v url="$url" '$2 == url { found = 1 } END { exit !found }' "$manifest"; then
    fail "index.md references a source URL absent from $manifest: $url"
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

printf 'Docs index check passed for %s mirrored pages, %s canonical source rows, %s verified content fingerprints, %s source attributions, %s paired index source links, %s unique llms source URLs, %s index source URLs, %s local doc links, %s heading fragments, %s HTML redirect links, and %s docs plans.\n' "$count" "$manifest_count" "$fingerprint_count" "$source_attribution_count" "$index_source_pair_count" "$(printf '%s\n' "$urls" | sed '/^$/d' | wc -l | tr -d ' ')" "$(printf '%s\n' "$index_source_urls" | sed '/^$/d' | wc -l | tr -d ' ')" "$link_count" "$fragment_count" "$redirect_count" "$plan_count"
