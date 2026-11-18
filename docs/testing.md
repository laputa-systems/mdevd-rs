# Local verification

| Command | Evidence |
| --- | --- |
| `tools/check-combined.sh` | One disposable KVM guest runs the pinned mdevd + seatd + doas candidates plus a real static libudev-zero consumer: mdevd node creation and framed output, consumer-observed add/change/remove with device state, seatd admission on virtual DRM/input with restart reclaim and no-steal, setuid doas narrow permit and unauthorized deny, SIGTERM shutdown for both daemons |
| `cargo test --locked -q -- adversarial` | Ancestor confinement, leaf symlink refusal, netlink truncation and spoof flood, output backpressure, restart during coldplug |
| `tools/check-privileged.sh` | Real character and block nodes, identity adoption, modes, ownership, aliases, replacement safety, FD stability, kernel-event publication |
| `tools/check-udev-consumer.sh` | Isolated netlink multicast and the pinned libudev-zero consumer. Both tests require explicit selection and fail if their prerequisites are missing. |
| `tools/check-qemu.sh` | Real kernel `add` with major/minor drives node creation, framed `-o` output, and coldplug sync in a KVM guest |
| `cargo test --locked -q --test engine --test bins --test parity --test config` | Engine behavior, daemon lifecycle, corpus goldens, and CLI contract |
| `make coverage` | Branch coverage for the ordinary Rust suites, written to `.work/coverage/report.json` |
| `cargo clippy --locked -q --all-targets` | Rust lint checks |

Coverage uses cargo-llvm-cov 0.9.1 and the pinned Rust toolchain's
`llvm-tools` component. Run it on a Linux host that permits the
ordinary tests to create their own user and network namespaces.
The hosted x86-64 trial passed 64 tests with ten opt-in cases ignored.
It covered 1,657 of 2,114 lines and 390 of 566 branches.
[Hosted coverage trial](https://github.com/laputa-systems/mdevd-rs/actions/runs/44360634905/job/135000705986)

`tools/check-privileged.sh` requires Linux x86_64, the pinned Rust toolchain,
Docker access, a local `ubuntu:24.04` image, BusyBox at `/bin/busybox`,
and the musl loader at `/lib/ld-musl-x86_64.so.1`.
It compiles the static musl test binary and runs the suite inside
locked-down containers.
A missing prerequisite or failed test fails the command.
The privileged tests are explicitly ignored by ordinary Cargo runs.

Both containers mount the repository read-only and overlay `.work/tmp` with private tmpfs.
The device container receives only `MKNOD`, `CHOWN`, and `FOWNER` capabilities.
The kernel-event container receives only `NET_ADMIN` and uses a private network namespace.
Neither container receives host device mounts or host networking.

The kernel test creates and removes a dummy interface through rtnetlink.
The daemon receives genuine kernel events, including interface queue events.
The test compares every captured kernel datagram with the daemon's `-o` framing and `-O 4` rebroadcast, in order.
It waits for `-D` readiness before triggering events and requires clean SIGTERM exit.
A FIFO handshake holds reload open while the kernel queues add events.
It never writes host sysfs.

Network events lack device major and minor numbers, so this test does not exercise daemon-driven device creation.
The device tests exercise the real filesystem adapter on private tmpfs instead.
RealOps rejects symlink ancestors for mutations and retains the verified device inode for subsequent metadata changes.
Its chmod implementation requires `/proc/self/fd` to update that inode without opening the device.

Event loss stays observable: netlink overruns increment a counter and
emit a level-0 `missed events! you should increase the -b kbufsz value`
warning. No synchronized-state claim follows an
overrun; re-establishing device state requires a rescan
(`mdevd-coldplug -s /sys`).

`tools/check-qemu.sh` requires Linux x86_64 with KVM (`/dev/kvm`),
`qemu-system-x86_64`, `mkfs.ext4`, and `apk`. It builds a pinned Alpine
guest (minirootfs 3.20.3 plus the locked package set in
`guest/packages.sha256`, following tinyland's harness as prior art) with
the musl-static Rust daemon and coldplug, then boots it
with KVM on a private disk image under `.work/`. The guest init triggers a
real kernel `add` via `/sys/block/vda/uevent`, and the daemon must create
the matching block node (identity from `/sys/block/vda/dev`, mode 660),
emit framed `-o` output carrying `ACTION`, `DEVNAME`, `MAJOR`, and `MINOR`,
pass a real `mdevd-coldplug -s /sys -O 4` sync, and exit 0 on `SIGTERM`.
Guest mutations stay inside the guest; host sysfs and `/dev` are untouched.
