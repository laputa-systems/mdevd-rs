.PHONY: test lint coverage

test:
	cargo test --locked -q
	sh tools/test-check-udev-consumer.sh

lint:
	cargo clippy --locked -q --all-targets

coverage:
	mkdir -p .work/coverage .work/tmp
	TMPDIR="$(CURDIR)/.work/tmp" cargo llvm-cov --locked --branch --json --output-path .work/coverage/report.json
