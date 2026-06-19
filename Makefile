.PHONY: check check-sources record-refresh lint test build verify

check: verify

check-sources:
	scripts/check-source-availability.sh

record-refresh:
	@test -n "$(SLUG)" && test -n "$(VERIFIED_AT)" || (echo "usage: make record-refresh SLUG=<slug> VERIFIED_AT=<YYYY-MM-DD>" >&2; exit 1)
	scripts/record-mirror-refresh.sh "$(SLUG)" "$(VERIFIED_AT)"

lint:
	scripts/check-docs-index.sh

test: lint
	scripts/test-source-availability.sh
	scripts/test-mirror-refresh.sh

build: lint

verify: lint test build
