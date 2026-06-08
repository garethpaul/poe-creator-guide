.PHONY: lint test verify

lint:
	scripts/check-docs-index.sh

test: lint

verify: lint
