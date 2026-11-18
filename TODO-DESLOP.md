Prefix: DSLP
Next: 6

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

## Tickets

### DSLP-2 · P2 · Diagnose: ultrareview into this backlog

- **Area:** deslop · diagnose
- **Where:** whole repository
- **Problem:** No review has ranked this repository's risks for the deslop pass.
- **Recommendation:** Run the deslop Diagnose step. Accept: the diff touches only docs, comments, and this file, and every finding names its Fix with.
- **Fix with:** deslop
- **Effort:** S

### DSLP-3 · P2 · Types: strict profile and typing findings

- **Area:** deslop · types
- **Where:** type checker and lint configuration; Rust/Python sources
- **Problem:** The strict-profile candidates in the deslop skill's tools reference have not been measured here.
- **Recommendation:** Run the deslop Types step. Accept: clean at the adopted profile, escape hatches not increased, witnesses recorded.
- **Fix with:** deslop
- **Effort:** M

### DSLP-4 · P2 · Tests: coverage, boundary gaps, mutation

- **Area:** deslop · tests
- **Where:** test suites and CI
- **Problem:** Coverage and mutation results are unmeasured; no deslop mutation lane exists.
- **Recommendation:** Run the deslop Tests step. Accept: no undispositioned survivor in critical code, the test cost budget holds, and the lane is green where the tools are mirrored.
- **Fix with:** deslop
- **Effort:** M

### DSLP-5 · P2 · Dead code: tools and debloat

- **Area:** deslop · dead code
- **Where:** whole repository
- **Problem:** No dead-code scan has run.
- **Recommendation:** Run the deslop Dead code step. Accept: tools clean or allowlisted with reasons; walk-backs filed as Needs owner tickets.
- **Fix with:** deslop
- **Effort:** M

