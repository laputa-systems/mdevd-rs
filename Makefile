.PHONY: test lint

test:
	cargo test --locked -q
	sh tools/test-check-udev-consumer.sh

lint:
	cargo clippy --locked -q --all-targets
