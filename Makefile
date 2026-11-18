.PHONY: test lint

test:
	cargo test --locked -q

lint:
	cargo clippy --locked -q --all-targets
