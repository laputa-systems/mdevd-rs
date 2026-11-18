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
`scan_decimal`, `scan_octal` and `validate_v1`. It caught seven and
classified seven as unviable.

The same runner tested all 147 identities in the two table-driven
parser passes. After retrying both initial timeouts at 30 seconds,
51 were caught, 88 were unviable, seven survived and one still hung.
The repeated hang changes the first-pass input offset increment to
multiplication, leaving offset zero at zero. Four survivors change
the first-pass rule or environment counters. Three change when the
second pass records path or command offsets. Those survivors remain
open under DSLP-4.

To repeat, run Cargo-mutants 27.1.0 on a fresh archive of
`f5dacd088da84260022288780f678a449d280e6e` inside the pinned
fleet musl image. Run
`cargo mutants --baseline run --gitignore true --jobs 2 --timeout 10 --build-timeout 60 --file src/config/mod.rs --re 'first_pass|second_pass' -- --test config`.
Set the same filter to `scan_decimal|scan_octal|validate_v1` for the
14-identity scope. Retry the two exact timeout identities at 30
seconds and reconcile the outcomes by mutant identity.

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

## Tickets



### DSLP-4 · P2 · Tests: coverage, boundary gaps, mutation

- **Area:** deslop · tests
- **Where:** test suites and CI
- **Problem:** Native ARM64 parser mutation has seven survivors and one confirmed hang. Coverage, the remaining device and publication decisions, and whole-change retention are open.
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


### DSLP-6 · P3 · Reject non-UTF-8 CLI arguments with the usage exit

- **Area:** command-line argument admission
- **Where:** src/bin/mdevd.rs; src/bin/mdevd-coldplug.rs; tests/bins.rs
- **Problem:** Both binaries panic with exit 101 when given an OS argument containing byte FF. Their existing invalid-argument contract uses exit 100. Reproduced in an isolated ARM64 musl container before any daemon effect.
- **Recommendation:** Read OS arguments and reject malformed UTF-8 at admission with exit 100. Test both built binaries with a byte-valued argument.
- **Fix with:** error-model
- **Effort:** S
