Prefix: DSLP
Next: 7

Deslop campaign backlog ([plan](https://github.com/laputa-systems/stuff/blob/main/docs/campaigns/deslop.md), tier A). One agent works this file with the `deslop` skill: take the lowest-numbered open ticket whose area does not start with `Needs owner ·`. After DSLP-5, work the open P1 and P2 findings, then fill in `## Report` below.

## Report

Ground (DSLP-1) passed at base `566b650c1676d83714bed9108c9d0d3f3290d38f`. Both hosted Linux runs passed 67 tests with eight separately enabled privileged cases ignored. [Verification](AGENTS.md#verification) lists the test costs, contracts, and guest checks.

Publication test admission at `425ed764d9b92c55e652326e592e4293a57fbf03`
found three tests counted by ordinary Cargo even if they performed no
exchange. The consumer test returned success without its fixture variables,
and the multicast test returned success on bind, connect or send failure.
The standalone socket test accepted both send outcomes without checking either.
The two exchange tests now report as ignored by default and require their
fixtures when selected. The wrapper checks the exchange markers and propagates
runner errors. The unasserted socket smoke was removed. The shell fixture
checks exact opt-in selection and failure propagation without opening netlink.
The real Linux namespace exchange remains a separate verification boundary.

The default build at `dd4d59a5a0eb7a38aac973630f60ac768de0e03d`
passed 64 tests and explicitly ignored ten opt-in cases. The same
shell witness now runs through `make test`. It refuses the old
selection without `--ignored` and propagates a failed test status.
The existing CI provisioning already supplies ripgrep. The fixture
uses local command stubs and leaves the live namespace checks separate.

Diagnose at `37a4d96f4bc2efa004bcda2d0c7ff5cd11d58737` ranks the
configuration parser and ordered device decisions first for mutation.
Their fixtures cover corpus parity and planned effects. Native lifecycle,
node creation and rebroadcast have separate verification commands in
[Local verification](docs/testing.md). Their acceptance requires the
real Linux effects alongside the ordinary tests.

Both Linux binaries collect their OS arguments as UTF-8 before calling
the usage parser. A byte outside UTF-8 gives both commands exit 101 and
a Rust panic instead of the ordinary usage exit 100. This reproduced
with the locked ARM64 musl debug binaries in the stable Alpine container.
The commands need no device mount, capabilities or networking to
reproduce the panic.

Types measured the production library and both binaries with the pinned
nightly on ARM64 musl. Counts are unique source locations.

| Candidate | Before | After | Disposition |
| --- | ---: | ---: | --- |
| `unsafe_code` | 52 | 52 | Keep the required Linux and libc FFI |
| `cast_possible_truncation` | 13 | 13 | Keep bounded and platform ABI conversions |
| `cast_sign_loss` | 3 | 3 | Keep conversions guarded by sign checks |
| `expect_used` | 2 | 2 | The configuration accessor and regex clone rely on parser invariants |
| `unwrap_used` | 4 | 3 | Bind the device numbers through their options. The remaining sites construct NUL-free strings |
| `needless_pass_by_value` | 8 | 8 | Preserve descriptor ownership and existing diagnostic signatures |
| `wildcard_enum_match_arm` | 2 | 2 | Retain equivalent error handling for the grouped variants |
| `match_wildcard_for_single_variants`, `redundant_clone` | 0 | 0 | No witness for adoption |

The add branch now receives both numbers from a single option pattern.
The 11 engine tests passed in the pinned Alpine 3.24.2 ARM64 container.
Forcing the node-change flag off failed `engine_dry_basic` on the
missing mknod and chmod transcript. Restoring the condition restored
the pass. The release engine storm held RSS at 568 kB and file
descriptors at four across the measured 10,000 events.

Tests ran the seven config tests in the fleet's native ARM64 musl
toolchain image. Cargo-mutants 27.1.0 tested 14 identities across
`scan_decimal`, `scan_octal` and `validate_v1` serially and caught all 14.

The two table-driven parser passes accounted for all 147 selected
identities in the same serial run. It caught 124, left 18 survivors,
and timed out on two changed offset increments. Three replacements
were unviable because `Rule` or `EnvMatch` lacks a `Default`
implementation. Parallel local runs classified intermittent
missing-object linker failures as unviable. The serial run supersedes
those counts. The surviving parser decisions remain open under DSLP-4.

To repeat, run Cargo-mutants 27.1.0 on a fresh archive of
`f5dacd088da84260022288780f678a449d280e6e` inside the pinned
fleet musl image. Set `CARGO_INCREMENTAL=0` and
`CARGO_BUILD_JOBS=1`. Run
`cargo mutants --baseline run --gitignore true --jobs 1 --timeout 30 --build-timeout 60 --file src/config/mod.rs --re 'first_pass|second_pass|scan_decimal|scan_octal|validate_v1' --cargo-test-arg=--test --cargo-test-arg=config`.
Reconcile the outcomes by mutant identity.

With cargo-llvm-cov 0.9.1 and the pinned Rust llvm-tools component,
the config, engine, publish and uevent suites passed 27 tests, with
two live publication tests ignored. Branch coverage describes that
scope only.

| Source subtree | Lines | Branches |
| --- | ---: | ---: |
| `src/config` | 414/442 | 105/116 |
| `src/engine` | 399/608 | 99/188 |
| `src/publish` | 47/114 | 7/22 |
| `src/uevent` | 92/159 | 26/42 |

Run `cargo llvm-cov --locked --branch --test config --test engine --test publish --test uevent`
in the same native image. The full instrumented suite stopped because
the container denied the test's user-namespace creation. Full binary,
lifecycle and live publication coverage still require their Linux
verification environments.

The [native x86-64 census](https://github.com/laputa-systems/mdevd-rs/actions/runs/44362505578)
started with passing ordinary suites in all three shards. The results
matched every selected identity.

| Scope | Selected | Caught | Survived | Unviable | Timed out |
| --- | ---: | ---: | ---: | ---: | ---: |
| Config | 196 | 167 | 18 | 9 | 2 |
| Engine | 154 | 127 | 23 | 3 | 1 |
| Event intake and publication | 113 | 71 | 33 | 6 | 3 |

The record tests now check that a bare field and a longer name cannot
shadow the first matching variable, that a header-only record is empty,
and that fatal intake and broken-pipe errors keep their diagnostics.
Ten ordinary event and publication tests passed, with two live tests
ignored. A native ARM64 comparison selected the same 20 exact
identities and moved from 15 caught and five survivors to 20 caught.
Parallel local trials had intermittent missing-object linker failures.
The matched comparison ran serially with `CARGO_INCREMENTAL=0` and
`CARGO_BUILD_JOBS=1`.

Use Cargo-mutants 27.1.0 with the source paths
`src/uevent/mod.rs` and `src/publish/mod.rs`, and select
`errno_msg|Uevent::is_empty|Uevent::getvar|Display for Fatal`.
Pass `--jobs 1 --timeout 10 --build-timeout 60 --cargo-test-arg=--test --cargo-test-arg=publish --cargo-test-arg=--test --cargo-test-arg=uevent`.
Kernel-level and live consumer decisions retain their separate tests.

The engine now exercises the longest accepted literal node path and the
longest accepted path after appending a device name. Both cases check
rejection of the next byte without creating a node. The 12 engine tests
passed. Serial cargo-mutants 27.1.0 on the pinned ARM64 musl builder selected
the same 14 `node_for` and path-limit identities at base `1570f52` and
with the fixture. The original suite caught seven and missed seven. The
fixture caught all 14.

The [native KVM proof](https://github.com/laputa-systems/mdevd-rs/actions/runs/44373744734)
passed for the same daemon and coldplug sources. The guest kernel's
actual block device add produced the expected node identity, mode and
framed record. Coldplug sync and graceful daemon shutdown also passed.
The build harness now stops on failed preparation and supports the
disposable builder's container root.

The [native consumer run](https://github.com/laputa-systems/mdevd-rs/actions/runs/44375183367)
passed the group-4 multicast round trip and the pinned libudev-zero
consumer's add, change and remove sequence with observed device state.
The harness fetches the locked Cargo inputs before entering the private
network namespace. Direct hardware coldplug remains open.

Four first-pass census survivors changed only the parser's discarded
second counter. The sole caller has discarded it since the initial
port at `cb2c927`. Removing that count preserves the rule bound used by
the debug assertion. The native ARM64 config tests passed, including
every checked-in grammar corpus result. The ordinary hosted suite
exercises the namespace-dependent parity cases.

Single-byte move and hook tokens now exercise capture at the first
state exit. A malformed second rule also checks that the column is
relative to its source line. All nine config cases passed on native
ARM64. Serial cargo-mutants 27.1.0 selected the same eight identities
at `4921c11` and with the tests, using `--test config` and the
`src/config/mod.rs:(357|363|546):` expression. The result moved from
three caught and five surviving to six caught and two equivalent,
with zero build errors or timeouts.

The two surviving `&&` to `||` replacements capture a token's saved
offset earlier. All 11 `A_PATH` and 15 `A_CMD` actions enter their
matching token state without `A_FINAL`. Same-state transitions carry
neither capture nor finalization flags. The rule reads the saved fields
only at `A_FINAL`, so both versions emit the same offsets. Separately,
walking the table from state zero covered 42 parser-state and
numeric-device combinations. Every numeric action had a numeric
device after the row's initializers. The six mutations of the
non-numeric guard mask therefore preserve behavior with this table.


Both command entry points now decode OS arguments before option parsing.
Invalid UTF-8 follows the existing usage path and exits 100 before daemon
or coldplug effects. The native ARM64 regression exercised both binaries
and checked the exit, stderr usage and empty stdout. The daemon baseline
returned 101 before the change. The ordinary CLI and binary parser cases
and Clippy passed in the same Alpine builder.


The engine now verifies that valid event numbers win as a pair, invalid
numbers fall back to the complete sysfs pair, and an unterminated sysfs
`DEVNAME` reaches the actual node decision. At the exact device-name
limit the dry run reports the expected warning. All 14 engine cases
and Clippy passed on native ARM64 musl.

Serial cargo-mutants 27.1.0 selected the same 44 engine mutations at
`8f38cb9` and with the new cases. Select `--file src/engine/mod.rs`,
`--cargo-test-arg=--test --cargo-test-arg=engine` and the line expression
`src/engine/mod.rs:(38[4-9]|39[0-9]|40[0-9]|42[6-9]|4[6-9][0-9]|5[01][0-9]|52[0-3]):`.
The baseline caught 38 and missed five. The candidate caught 40 and
missed three. Both had one compiler rejection because `Device` has
no `Default`. The lookup's nonempty constant needle makes the changed
short-input guard equivalent. The other two lookup variants differ
only when the file contains exactly the marker and no device name.
That malformed-file boundary and wider engine mutation stay in DSLP-4.

## Tickets



### DSLP-4 · P2 · Tests: coverage, boundary gaps, mutation

- **Area:** deslop · tests
- **Where:** test suites and CI
- **Problem:** The verified native x86-64 census has open survivors and timeouts in the config, engine and event I/O scopes. The narrower serial ARM64 parser rerun has 18 survivors and two timed-out identities. The whole-change retention gate and eligible native effect checks remain open.
- **Recommendation:** Disposition the parser identities and qualify engine, lifecycle and publication checks with ordinary coverage and isolated native evidence. Accept a measured fail-closed whole-change lane before closing.
- **Fix with:** deslop
- **Effort:** M

### DSLP-5 · P2 · Dead code: tools and debloat

- **Area:** deslop · dead code
- **Where:** whole repository
- **Problem:** No dead-code scan has run.
- **Recommendation:** Run the deslop Dead code step. Accept: tools clean or allowlisted with reasons; walk-backs filed as Needs owner tickets.
- **Fix with:** deslop
- **Effort:** M
