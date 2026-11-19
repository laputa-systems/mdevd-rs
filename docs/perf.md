# Performance

Methodology and the Charter thresholds. Absolute numbers are logged for the
record; only egregious regressions gate the run. The host during this
campaign is busy (load ~50 on 32 cores), so spreads are wide and
quiet-host confirmation stays open. See [local verification](testing.md)
for the test boundary and the [divergence register](divergence.md) for
behavioral deltas that perf does not move.

Run `tools/measure-perf.sh`. It builds the Rust release binaries, then:

- Coldplug: 6 runs on a synthetic tree (3 subsystems, 100 devices each,
  300 `uevent` files on tmpfs). Reports each run, median, and min-max
  spread. Timing is logged, not gated.
- Engine storm: `cargo bench --bench storm` warms 10k events, then measures
  10k more for `VmRSS` growth and `/proc/self/fd` delta. Gates only growth
  `>5%` and delta `!= 0`. The adapter under test reuses one `FakeOps`,
  like the daemon reuses one `RealOps`.
- Microbenchmarks: `cargo bench --bench parse` (Laputa config) and
  `--bench handle` (single `sda` event) are logged, not gated.
- Idle: the daemon starts with `-I 1`, signals readiness via `-D`, sleeps
  3 seconds; its `utime + stime` ticks from `/proc/<pid>/stat` must read
  zero. Gates on any nonzero tick count.

## Representative run (busy host, 2026-10-28)

Coldplug (microseconds, 300 files, Rust only):

- Rust: median ~17.9 ms, spread ~16.3-57.5 ms

Engine storm:

- `rss_before=644kB rss_after=644kB growth=0.00%` (gate `>5%` fails)
- `fds_before=4 fds_after=4` (gate `!= 0` fails)

Microbenchmarks:

- `bench_parse_laputa`: ~670 us per iteration
- `bench_handle_sda`: ~3.7 us per iteration

Idle (3 seconds):

- `rust_cpu_ticks=0` (gate: must read zero)

Result: `measure-perf: OK`. No threshold tripped. The wide coldplug spread
tracks host load, not the implementation.

## Benchmark entrypoint

`make bench` is manual-only and selects the full registry. Use
`make bench-list` to list workloads, estimated costs and requirements, and
`make bench-check BENCH_ARGS='--tier edit'` to check a selection without
running it. `make bench BENCH_ARGS='--tier change --area engine --skip storm'`
selects handling; `--workload NAME` selects a workload, `--area AREA` selects
an area, and `--skip NAME` removes a workload. Repeat selectors to form a
union within each kind; kinds intersect. Unknown selectors and an empty result
fail. `--dry-run` prints selected commands and exclusions without writing.

The registry assigns driver tests to Edit, individual storm, parse and handle
benches to Change, the combined `measure-perf.sh` to Scenario, and the two
KVM guest checks to Full. The latter are correctness and lifecycle checks,
not latency measurements. Change and Scenario require the pinned nightly and
Linux. Timing workloads also require `perf-gate-ready` before and after the
run; a failed readiness check makes timing unavailable. Full requires an
x86_64 Linux KVM host and the guest harness prerequisites in
[testing.md](testing.md). The registry's costs are estimates; guest costs are
environment-dependent. `cargo` builds its own current artifacts. The guest
harnesses maintain their own pinned inputs and outputs under `.work/`.

Each execution writes a dated `.work/bench/` directory with workload logs and
`summary.txt`, including exclusions, status and elapsed time. Timings remain
inconclusive without a matched baseline, even if a command succeeds. Storm's
RSS and fd gates apply to the benchmark process after warmup, not a concurrent
process tree or absolute RSS. Idle CPU ticks cover the daemon process, not
wakeups. Coldplug uses a synthetic 300-file tree; parse and handling use one
fixture and handling uses `FakeOps`. These do not establish real-device storm
throughput or tail latency. The guest commands have their own output paths
under `.work/` and require their prerequisites before use.

For diagnosis, collect Linux `perf record` or `strace -c` separately from
timed runs; instrumentation changes execution cost and process or guest
scope must be recorded. Allocation attribution and guest-wide profiling are
not currently provided. The combined performance script pipes some benchmark
commands, so its success alone cannot establish that every benchmark passed;
run the individual Change workloads for direct exit status.
