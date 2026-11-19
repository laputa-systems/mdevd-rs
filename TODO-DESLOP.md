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

DSLP-4 closed under the revised mutation policy. The required scope is
uevent variable parsing and framing (`src/uevent/mod.rs`, `src/publish/mod.rs`),
node path admission and length limits (`node_for`), node creation decisions
including empty names and sysfs record parsing (`src/engine/mod.rs`), and
argument admission and usage exit 100 (both `src/bin/` entry points). Ordinary
`uevent`, `publish`, `engine`, `config`, and `bins` tests protect these
boundaries, including first matching fields, broken pipes, path limits,
number-pair fallback, unterminated and empty sysfs names, and invalid UTF-8.
The config corpus and capture tests protect parser boundaries.

Focused serial ARM64 comparisons caught 20/20 event and pipe identities and
14/14 node-path identities (base `1570f52`). At `4921c11` eight parser capture identities moved
from three caught and five surviving to six caught and two equivalent. Those
two save offsets earlier, but all 11 `A_PATH` and 15 `A_CMD` entries
enter without `A_FINAL`, same-state transitions have neither capture nor
finalization flags, and the fields are read only at finalization. All 42
reachable parser-state and numeric-device combinations have a numeric device
when a numeric action runs, making six guard-mask variants equivalent. Four
first-pass survivors only changed a discarded counter; that counter was removed.
In the 44-identity engine comparison at `8f38cb9`, the remaining short-input
lookup guard was equivalent for its nonempty needle; two empty-name variants
were addressed by the empty-name skip regression. Changing the `find_sub` length guard from `<` to `<=` or `==`
failed `engine_distinguishes_an_empty_sysfs_name_from_an_absent_one`. Invalid
UTF-8 previously produced exit 101; the CLI regression now checks exit 100
for both commands.

The broader [x86-64 census](https://github.com/laputa-systems/mdevd-rs/actions/runs/44362505578)
was advisory: config 167 caught, 18 survived, nine unviable, two timed out;
engine 127 caught, 23 survived, three unviable, one timed out; event I/O 71
caught, 33 survived, six unviable, three timed out. These counts predate the
focused changes above and cannot be added to their results. The serial parser
run at `f5dacd088da84260022288780f678a449d280e6e` left 18 survivors and
two timeouts; it too predates the focused changes. Remaining broad survivors are unclassified and timeouts are incomplete, not passes. Wider
mutation and the whole-change retention lane are unrun under this policy. No
new mutation trial was run in this closure (zero runner-minutes).

The [native KVM proof](https://github.com/laputa-systems/mdevd-rs/actions/runs/44373744734)
covered a real block-device add, coldplug sync and daemon shutdown; the
[native consumer run](https://github.com/laputa-systems/mdevd-rs/actions/runs/44375183367)
covered the group-4 exchange. Physical coldplug and live hardware remain
environment-dependent items, not claims of this closure. Storm and idle
resource gates passed on the declared Linux workload. Branch coverage was a
report for config, engine, publish and uevent, not a gate; full lifecycle and
live publication coverage require their Linux environments.

## Tickets




### DSLP-5 · P2 · Dead code: tools and debloat

- **Area:** deslop · dead code
- **Where:** whole repository
- **Problem:** No dead-code scan has run.
- **Recommendation:** Run the deslop Dead code step. Accept: tools clean or allowlisted with reasons; walk-backs filed as Needs owner tickets.
- **Fix with:** deslop
- **Effort:** M
