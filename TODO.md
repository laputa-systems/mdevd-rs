Prefix: MDEV
Next: 4

# Open work
### MDEV-1 · P3 · Measure real event throughput and latency

- **Area:** Bench
- **Where:** benches/handle.rs; benches/storm.rs; tools/measure-perf.sh
- **Problem:** FakeOps synthetic events do not establish completed real daemon throughput or tail latency; a user-visible regression may be missed.
- **Recommendation:** Add a correctness-checked production-path workload and matched baseline with a suitable latency distribution.
- **Fix with:** bench-pyramid
- **Effort:** L

### MDEV-2 · P3 · Strengthen resource and timing regression evidence

- **Area:** Bench
- **Where:** benches/storm.rs; tools/measure-perf.sh; docs/perf.md
- **Problem:** RSS growth after warmup misses an absolute footprint increase; idle ticks omit wakeups and coldplug and parse timings lack an accepted baseline. Regressions in user-visible resources can pass.
- **Recommendation:** Define scoped absolute resource anchors and wakeup measurements and compare timings against an accepted interleaved baseline on a qualified host.
- **Fix with:** bench-pyramid
- **Effort:** L

### MDEV-3 · P3 · Add benchmark attribution and robust harness failure propagation

- **Area:** Bench
- **Where:** tools/measure-perf.sh; docs/perf.md
- **Problem:** The piped cargo bench commands can hide a failure and no CPU, allocation, syscall or guest attribution path is documented; diagnosing a change requires extra investigation.
- **Recommendation:** Propagate each harness status and document separate perf and syscall profiling runs with their scope and overhead.
- **Fix with:** bench-pyramid
- **Effort:** M

