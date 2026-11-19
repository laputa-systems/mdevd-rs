Prefix: DSLP
Next: 10

Deslop campaign backlog ([plan](https://github.com/laputa-systems/stuff/blob/main/docs/campaigns/deslop.md), tier A). One agent works this file with the `deslop` skill: take the lowest-numbered open ticket whose area does not start with `Needs owner ·`. After DSLP-5, work the open P1 and P2 findings, then fill in `## Report` below.

## Report

DSLP-1 base: `566b650c1676d83714bed9108c9d0d3f3290d38f`;
report review head: `cb395e0444757dcfdcac23eeea298dc98d39c2dc`.
The cumulative review found no additional demonstrated defects or supported
new findings. It checked changed parsing, device-name and number selection,
rule decisions, node permissions, command rejection, event framing, CLI
admission, test fixtures and harnesses against their callers and tests.

| Scorecard | Before | After / disposition |
| --- | --- | --- |
| Rust source / test lines | 3,289 / 2,691 | 3,295 / 2,770; physical lines in `src/**/*.rs` and `tests/**/*.rs` |
| Warm `make test` | 2.57 s, hosted x86-64 | Not measured on an equivalent host; ARM64 container fails on the same two `unshare` tests as base, so no valid warm comparison |
| Line / branch coverage | Not recorded | 1,657/2,114 lines; 390/566 branches in the [hosted trial](https://github.com/laputa-systems/mdevd-rs/actions/runs/44360634905/job/135000705986), before later tests; final coverage not measured |
| Escape-hatch matches | 70 source, 322 test | 68 source, 333 test; `unsafe`, allow attributes, `unwrap()` and `expect()` occurrences, including comments |
| Dead code | Not quantified | Discarded first-pass counter and unused second-pass return removed; zero dependencies removed. Removal line count not separately recorded |
| Findings | P1: 0; P2: 8 filed, including five campaign steps and DSLP-6; P3: 1; P4: 0 | Six P2 closed, DSLP-7 and DSLP-8 open; DSLP-9 open. No P1/P3/P4 fixed. Two product defects fixed: invalid UTF-8 CLI panic and empty device-name node operation |
| Performance | No matched campaign baseline | Storm RSS/fd and idle resource gates passed in recorded runs; timing regression verdict inconclusive without qualified matched runs. DSLP-7 and DSLP-8 remain environment-blocked pending a quiet native host and real devices |
| Escaped regressions | Not measured | None demonstrated by completion review; real hardware coldplug and physical devices remain unverified |

Six behavior groups gained protection: event admission and framing; output
failures; node path limits; parser captures and diagnostics; device number
and name selection; and CLI argument admission. Mutation outcomes are evidence
about those behaviors, not a count of defects fixed.
The required scopes were event variable parsing and framing, publication,
node paths and decisions, sysfs records, and CLI admission. Focused ARM64
serial comparisons caught 15/20 then 20/20 event/pipe identities and 7/14
then 14/14 node-path identities; the recorded final selections had no misses,
timeouts or unviable cases. The parser capture selection moved from 3 caught /
5 missed to 6 caught / 2 equivalent (no timeouts or unviable cases recorded
for that comparison). Two empty-name variants led to one fixed defect; the
44-identity engine comparison also left an equivalent short-input guard.
Equivalent numeric guard-mask variants retain fail-closed checks. Required
scope was dispositioned by behavior, not as a single whole-scope run; CLI
and sysfs tests have direct fault witnesses. Runner-minutes for the earlier
focused runs were not recorded; Tests closure added zero runner-minutes.
The whole-change retention lane was not run.

The earlier [x86-64 census](https://github.com/laputa-systems/mdevd-rs/actions/runs/44362505578) was **advisory**, not additive to those comparisons:
config 167 caught / 18 missed / 2 timeout / 9 unviable; engine 127 / 23 / 1 /
3; event I/O 71 / 33 / 3 / 6. Remaining broad survivors and timeouts are
unclassified, not passes. Its runner-minutes were not recorded here. The
serial parser trial also predated the focused changes; 18 survived and two
timed out. See [Tests #27](https://github.com/laputa-systems/mdevd-rs/pull/27)
and Git history for scopes and proof.

| Step | Findings and cost |
| --- | --- |
| Ground | Established CI and verification boundaries. Two hosted runs passed 67 tests with eight ignored: 4.65 s cold, 2.57 s warm; warm lint about 1 s. CI minutes not recorded. |
| Diagnose | Ranked parser and ordered device decisions; reproduced invalid UTF-8 exit 101. Wall and CI minutes not recorded. |
| Types | Retained required FFI and rejected unwitnessed or noisy strict candidates; paired device numbers removed unchecked accesses. Eleven engine tests passed; timing and CI minutes not recorded. |
| Tests | Removed false-positive publication tests, added explicit fixture admission and protected event framing, node paths, parser captures, number/name selection and CLI errors. Fixed two product defects. Coverage and mutation evidence above; total wall and CI minutes not recorded. [Tests #27](https://github.com/laputa-systems/mdevd-rs/pull/27). |
| Dead code | rustc dead-code and unreachable-public checks and cargo-machete clean; no allowlist. Removed the unused parser return after checking callers, benches and package entry points. Wall and CI minutes not recorded. [Dead code #28](https://github.com/laputa-systems/mdevd-rs/pull/28). |
| Bench | Edit selector and Change storm proved; storm passed RSS/fd gates in 12 s on ARM64. Filed DSLP-7, DSLP-8 and DSLP-9; guest workloads need KVM. CI minutes not recorded. [Bench #29](https://github.com/laputa-systems/mdevd-rs/pull/29). |
| Report | Cumulative review and ARM64 base/candidate test and lint checks; cost not separately measured. No additional finding filed or fixed. |

Method feedback: a fixture admission rule requiring an explicit skip or failure
would have caught the publication tests that silently succeeded without an
exchange. The parallel linker mutation classifications misfired; serial
repeats corrected them. Dead-code scans found no unused dependency. Physical
coldplug and live hardware remain unverified; the recorded native KVM and
[libudev-zero run](https://github.com/laputa-systems/mdevd-rs/actions/runs/44375183367)
and [KVM run](https://github.com/laputa-systems/mdevd-rs/actions/runs/44373744734)
covered a virtual block device, shutdown and group-4 exchange.

Shared-file gaps: usr's deslop Report format asks for complete runner-minute
and before/after coverage totals, but the campaign did not retain all costs or
an equivalent final coverage run. The shared mutation guidance should require
recording scope, result classes and runner-minutes at each trial; stuff's
campaign should preserve those costs when closing a step. No shared file was
changed here.

## Tickets
### DSLP-7 · P2 · Measure real event throughput and latency

- **Area:** Bench
- **Where:** benches/handle.rs; benches/storm.rs; tools/measure-perf.sh
- **Problem:** FakeOps synthetic events do not establish completed real daemon throughput or tail latency; a user-visible regression may be missed.
- **Recommendation:** Add a correctness-checked production-path workload and matched baseline with a suitable latency distribution.
- **Fix with:** bench-pyramid
- **Effort:** L


### DSLP-8 · P2 · Strengthen resource and timing regression evidence

- **Area:** Bench
- **Where:** benches/storm.rs; tools/measure-perf.sh; docs/perf.md
- **Problem:** RSS growth after warmup misses an absolute footprint increase; idle ticks omit wakeups and coldplug and parse timings lack an accepted baseline. Regressions in user-visible resources can pass.
- **Recommendation:** Define scoped absolute resource anchors and wakeup measurements and compare timings against an accepted interleaved baseline on a qualified host.
- **Fix with:** bench-pyramid
- **Effort:** L


### DSLP-9 · P3 · Add benchmark attribution and robust harness failure propagation

- **Area:** Bench
- **Where:** tools/measure-perf.sh; docs/perf.md
- **Problem:** The piped cargo bench commands can hide a failure and no CPU, allocation, syscall or guest attribution path is documented; diagnosing a change requires extra investigation.
- **Recommendation:** Propagate each harness status and document separate perf and syscall profiling runs with their scope and overhead.
- **Fix with:** bench-pyramid
- **Effort:** M
