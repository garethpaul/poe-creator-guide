.PHONY: check lint test verify

check: verify

lint:
	scripts/check-docs-index.sh

test: lint

verify: lint
