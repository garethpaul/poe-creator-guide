.PHONY: check check-sources record-refresh lint test build root-test verify

override SHELL := /bin/sh
override .SHELLFLAGS := -c
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
override REPO_ROOT := $(shell path='$(subst ','"'"',$(MAKEFILE_LIST))'; path=$$(printf '%s' "$$path" | /usr/bin/sed 's/^ //'); [ -f "$$path" ] || exit 1; directory=$$(/usr/bin/dirname -- "$$path"); CDPATH= cd -- "$$directory" && /bin/pwd -P)
export REPO_ROOT
ifeq ($(strip $(REPO_ROOT)),)
$(error repository Makefile path could not be resolved)
endif

check: verify

check-sources:
	cd "$$REPO_ROOT" && scripts/check-source-availability.sh

record-refresh:
	@test -n "$(SLUG)" && test -n "$(VERIFIED_AT)" || (echo "usage: make record-refresh SLUG=<slug> VERIFIED_AT=<YYYY-MM-DD>" >&2; exit 1)
	cd "$$REPO_ROOT" && scripts/record-mirror-refresh.sh "$(SLUG)" "$(VERIFIED_AT)"

lint:
	cd "$$REPO_ROOT" && scripts/check-docs-index.sh

test: lint
	cd "$$REPO_ROOT" && scripts/test-docs-index.sh
	cd "$$REPO_ROOT" && scripts/test-source-availability.sh
	cd "$$REPO_ROOT" && scripts/test-mirror-refresh.sh
	cd "$$REPO_ROOT" && scripts/test-hard-link-mutations.sh

build: lint

root-test:
	cd "$$REPO_ROOT" && scripts/test-makefile-root.sh

verify: lint test build root-test
