.PHONY: check lint test build verify

check: verify

lint:
	scripts/check-docs-index.sh

test: lint

build: lint

verify: lint test build
