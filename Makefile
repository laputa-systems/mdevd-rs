.PHONY: test lint coverage

test:
	sh tools/test-bench.sh
	cargo test --locked -q
	sh tools/test-check-udev-consumer.sh

lint:
	cargo clippy --locked -q --all-targets

coverage:
	mkdir -p .work/coverage .work/tmp
	TMPDIR="$(CURDIR)/.work/tmp" cargo llvm-cov --locked --branch --json --output-path .work/coverage/report.json

.PHONY: bench bench-check bench-list

bench:
	sh tools/bench.sh $(BENCH_ARGS)

bench-check:
	sh tools/bench.sh --check $(BENCH_ARGS)

bench-list:
	sh tools/bench.sh --list
