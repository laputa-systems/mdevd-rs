# mdevd-rs

Linux Rust replacement for the mdevd hotplug daemon and the
`mdevd-coldplug` helper. Deny by default; fail closed on every error
path; no shell, no firmware loading, no hooks.

## Commands

```sh
make test
make lint
sh tools/check-qemu.sh
sh tools/check-combined.sh
sh tools/check-udev-consumer.sh
sh tools/measure-perf.sh
```

Musl release builds link with `mold` via `RUSTFLAGS="-Clinker=mold -Clinker-flavor=ld"`.

## Verification

- Two hosted x86_64 Linux runs of `make test` each passed 67 cases with eight privileged cases ignored. Elapsed time was 4.65 s with a fresh Cargo target and 2.57 s warm. The hosted Clippy step took about one second on the warm tree. [Cost measurement](https://github.com/laputa-systems/mdevd-rs/pull/6)
- `tests/bins.rs`, `tests/config.rs`, and `tests/parity.rs` exercise daemon and coldplug commands, configuration grammar, and golden behavior. `tests/engine.rs` covers policy decisions and adapter behavior.
- `tests/publish.rs` and the framing tests under `src/publish/` cover processed event output. The combined guest harness separately checks the libudev-zero consumer and daemon shutdown with real Linux events.
- The ordinary suite checks sealed filesystem and lifecycle cases. It also runs the publication wrapper regression with local command stubs and ripgrep. The real consumer exchange and device checks run separately; see [Verification](docs/testing.md).
- `make coverage` reports branches in the ordinary Rust suites on a Linux host with user namespaces. See [Local verification](docs/testing.md).
- The musl and QEMU smoke jobs exercise the built binaries. Boot and real kernel behavior require the separate Linux KVM guest harness.
- `tools/measure-perf.sh` runs the workloads described in [Performance](docs/perf.md). Use the declared workload when changing discovery, matching, or event publication.
- `tests/fixtures/pins.txt` records the upstream reference and fixture provenance.

## Invariants

- Config larger than 8191 bytes is rejected, never truncated.
- One effect adapter owns each mutation; no `unsafe` outside narrow FFI.
- Only `libc` in production (`tools/check-deps.sh` gates this).
- No `libudev` dependency; libudev-zero consumers read the `-O 4` rebroadcast.

## Map

- Config grammar and tables → `src/config/`
- Netlink intake → `src/uevent/`
- Match and apply → `src/engine/`, real adapter → `src/engine/ops.rs`
- Processed-event publication → `src/publish/`
- Daemon and coldplug binaries → `src/bin/mdevd.rs`, `src/bin/mdevd-coldplug.rs`
- Behavior contract and divergences → `docs/divergence.md`
- Verification, performance, release → `docs/testing.md`, `docs/perf.md`, `docs/artifacts.md`
- Guest harnesses and fixtures → `guest/`, `tools/check-*.sh`, `tests/fixtures/`
