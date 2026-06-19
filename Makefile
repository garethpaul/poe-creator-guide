.PHONY: check check-sources lint test build verify

check: verify

check-sources:
	scripts/check-source-availability.sh

lint:
	scripts/check-docs-index.sh

test: lint
	scripts/test-source-availability.sh

build: lint

verify: lint test build
