# Security Policy

## Supported Versions

The supported security scope for `poe-creator-guide` is the current default branch, `main`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: No GitHub description is currently set.

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/poe-creator-guide` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be a static web project. The active security scope is the code and documentation on the default branch.
- Review found authentication, token, or session-related code paths; changes in those areas should receive security-focused review before merge.
- Review found external API integrations or credential-adjacent configuration; changes in those areas should receive security-focused review before merge.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Review found database, model, query, or persistence-related code; changes in those areas should receive security-focused review before merge.
- Review found secret-like configuration names that require careful review before use; changes in those areas should receive security-focused review before merge.
- No primary dependency manifest was detected in the repository root. If dependencies are added later, include a manifest and prefer reproducible installation instructions.
- GitHub Actions runs the offline `make check` docs baseline before review.

## Service and API Notes

For web services, APIs, sockets, or scraping workflows, prioritize reports involving authentication bypass, authorization errors, injection, server-side request forgery, unsafe deserialization, credential leakage, data exposure, or denial-of-service conditions. Use test accounts and minimal proof-of-concept traffic only.

Mirrored documentation can shape production bot behavior. Keep each mirrored
page's source attribution comment intact as the first line so reviewers can
trace guidance back to the canonical Poe creator docs before applying it.
Keep each local index entry paired with its canonical Poe source URL so source
context cannot be shuffled across mirrored pages.
Keep canonical URLs and live-verification dates in `docs/sources.tsv`; use the
opt-in live audit separately from credential-free offline GitHub Actions.
Keep network-free live source audit tests in the canonical offline gate so curl
failure handling is verified without contacting upstream pages.
The offline mirror refresh recorder never downloads source content. It updates
one existing manifest date and fingerprint only after validating the reviewed
mirror's canonical first-line attribution; inspect the exact diff before any
optional live source audit.
Keep mirrored content fingerprints in the same manifest so an unreviewed local
page edit cannot retain valid source metadata while changing the reviewed text.
Reject source URLs in the local index that no longer map to checked-in mirrored
pages so readers are not sent to unreviewed or stale guidance.
Reject duplicate local or source entries in the local index so mirrored pages
cannot be listed twice with conflicting context.
Keep `index.html` redirect references pointed at one mirrored document so
refresh, canonical, and fallback links cannot send readers to different pages.
Keep local heading fragments aligned with checked-in Markdown headings so
content reorganizations cannot silently leave stale section links.
Reject legacy `doc:` and parent-relative Markdown targets so mirrored guide
navigation cannot bypass validated `/docs/...` paths.
The hosted validation workflow uses read-only repository access, a pinned
checkout action with credential persistence disabled, and the dependency-free
offline docs gate to reduce CI supply-chain and credential exposure.
Reject unexpected hosted files, symbolic links, and raw active Markdown HTML
outside fenced examples so the static mirror cannot publish unreviewed active
content alongside reviewed documentation.
Canonical Poe source URLs are validated with a shared helper before offline
manifest acceptance, live source requests, or refresh recording; dot segments,
encoded paths, query strings, fragments, and non-docs hosts are rejected.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
