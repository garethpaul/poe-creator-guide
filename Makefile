.PHONY: check check-sources record-refresh lint test build root-test verify

ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
override REPO_ROOT := $(shell path='$(subst ','"'"',$(MAKEFILE_LIST))'; path=$$(printf '%s' "$$path" | /usr/bin/sed 's/^ //'); directory=$$(/usr/bin/dirname -- "$$path"); CDPATH= cd -- "$$directory" && /bin/pwd -P)

check: verify

check-sources:
	cd "$(REPO_ROOT)" && scripts/check-source-availability.sh

record-refresh:
	@test -n "$(SLUG)" && test -n "$(VERIFIED_AT)" || (echo "usage: make record-refresh SLUG=<slug> VERIFIED_AT=<YYYY-MM-DD>" >&2; exit 1)
	cd "$(REPO_ROOT)" && scripts/record-mirror-refresh.sh "$(SLUG)" "$(VERIFIED_AT)"

lint:
	cd "$(REPO_ROOT)" && scripts/check-docs-index.sh

test: lint
	cd "$(REPO_ROOT)" && scripts/test-docs-index.sh
	cd "$(REPO_ROOT)" && scripts/test-source-availability.sh
	cd "$(REPO_ROOT)" && scripts/test-mirror-refresh.sh

build: lint

root-test:
	cd "$(REPO_ROOT)" && scripts/test-makefile-root.sh

verify: lint test build root-test
