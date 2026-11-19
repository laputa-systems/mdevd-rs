#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mode=run
tier=full
names=''
areas=''
skips=''
while [ "$#" -gt 0 ]; do
  case $1 in
    --check) mode=check; shift ;;
    --list) mode=list; shift ;;
    --dry-run) mode=dry; shift ;;
    --tier|--workload|--area|--skip)
      option=$1; shift
      [ "$#" -gt 0 ] || { echo "missing value for $option" >&2; exit 2; }
      case $option in
        --tier) tier=$1 ;;
        --workload) names="$names $1" ;;
        --area) areas="$areas $1" ;;
        --skip) skips="$skips $1" ;;
      esac
      shift ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
case $tier in edit) ceiling=1;; change) ceiling=2;; scenario) ceiling=3;; full) ceiling=4;; *) echo "unknown tier: $tier" >&2; exit 2;; esac
registry='driver|edit|harness|selection and preflight self-tests|seconds estimated|POSIX shell|sh tools/test-bench.sh
storm|change|engine|10k event RSS and fd gates|minutes estimated|Linux, cargo, pinned nightly|cargo bench --locked --bench storm
parse|change|config|config parsing timing|minutes estimated|Linux, cargo, pinned nightly|cargo bench --locked --bench parse
handle|change|engine|single event handling timing|minutes estimated|Linux, cargo, pinned nightly|cargo bench --locked --bench handle
measure|scenario|daemon|coldplug, storm, parsing, handling and idle gates|minutes estimated|Linux, cargo, python3, pinned nightly|sh tools/measure-perf.sh
qemu|full|guest|real kernel device and coldplug|environment-dependent|Linux x86_64, KVM, guest artifacts|sh tools/check-qemu.sh
combined|full|guest|real consumer and daemon lifecycle|environment-dependent|Linux x86_64, KVM, guest artifacts and sibling repositories|sh tools/check-combined.sh'
if [ "$mode" = list ]; then
  printf '%s\n' 'name|tier|area|purpose|cost|requirements|command'
  printf '%s\n' "$registry"
  printf '%s\n' 'logs and summary: .work/bench/<dated-run>/; guest harness artifacts: .work/'
  exit 0
fi
for name in $names $skips; do
  printf '%s\n' "$registry" | cut -d'|' -f1 | grep -x -F -q -- "$name" || { echo "unknown workload: $name" >&2; exit 2; }
done
for area in $areas; do
  printf '%s\n' "$registry" | cut -d'|' -f3 | grep -x -F -q -- "$area" || { echo "unknown area: $area" >&2; exit 2; }
done
selected=''
excluded=''
while IFS='|' read -r name level area purpose cost requirements command; do
  case $level in edit) rank=1;; change) rank=2;; scenario) rank=3;; full) rank=4;; esac
  reason=''
  [ "$rank" -le "$ceiling" ] || reason="above tier $tier"
  case " $names " in *" $name "*) :;; *) [ -z "$names" ] || reason='workload selector';; esac
  case " $areas " in *" $area "*) :;; *) [ -z "$areas" ] || reason='area selector';; esac
  case " $skips " in *" $name "*) reason='skipped';; esac
  if [ -n "$reason" ]; then excluded="${excluded}${name}: ${reason}
"; else selected="$selected $name"; fi
done <<EOF_REGISTRY
$registry
EOF_REGISTRY
[ -n "$selected" ] || { echo 'selection is empty' >&2; exit 2; }
printf 'selected:%s\n' "$selected"
printf '%s' "$excluded" | while IFS= read -r line; do [ -z "$line" ] || printf 'excluded: %s\n' "$line"; done
if [ "$mode" = dry ]; then
  printf '%s\n' "$registry" | while IFS='|' read -r name level area purpose cost requirements command; do
    case " $selected " in *" $name "*) printf '%s: %s\n' "$name" "$command";; esac
  done
  exit 0
fi
failed=0
if ! git rev-parse --verify HEAD >/dev/null 2>&1 || ! git status --porcelain >/dev/null 2>&1; then
  echo 'selected workloads: Git checkout unavailable; restore Git metadata and access' >&2
  failed=1
fi
for name in $selected; do
  case $name in
    driver) command -v sh >/dev/null || failed=1 ;;
    storm|parse|handle|measure)
      for tool in cargo rustc rustup; do command -v "$tool" >/dev/null || { echo "$name: missing $tool; install pinned Rust toolchain" >&2; failed=1; }; done
      [ "$(uname -s)" = Linux ] || { echo "$name: needs Linux; use a Linux builder" >&2; failed=1; }
      [ -f tests/fixtures/laputa-mdev.conf ] || { echo "$name: missing fixture; restore checkout" >&2; failed=1; }
      if command -v rustup >/dev/null && ! rustup toolchain list | grep -q '^nightly-2026-11-09'; then echo "$name: pinned nightly missing; install it with rustup" >&2; failed=1; fi
      case $name in parse|handle|measure)
        if ! command -v perf-gate-ready >/dev/null || ! perf-gate-ready; then echo "$name: timing host unavailable; install perf-gate-ready and retry when idle" >&2; failed=1; fi ;;
      esac
      if [ "$name" = measure ]; then command -v python3 >/dev/null || { echo 'measure: missing python3; install python3' >&2; failed=1; }; fi ;;
    qemu|combined)
      for tool in qemu-system-x86_64 python3 cargo bash cc mold mkfs.ext4; do command -v "$tool" >/dev/null || { echo "$name: missing $tool; install guest prerequisites" >&2; failed=1; }; done
      [ ! -S .work/qmp-mdevd.sock ] && [ ! -S .work/combined/qmp.sock ] || { echo "$name: guest socket exists; stop the previous guest and remove its stale socket" >&2; failed=1; }
      [ "$(uname -s)" = Linux ] && [ "$(uname -m)" = x86_64 ] && [ -c /dev/kvm ] || { echo "$name: needs x86_64 Linux and /dev/kvm; use a KVM builder" >&2; failed=1; }
      space=$(df -Pk . | awk 'NR == 2 {print $4}')
      case $space in ''|*[!0-9]*) echo "$name: cannot determine free disk; check filesystem" >&2; failed=1;; *) [ "$space" -ge 2097152 ] || { echo "$name: less than 2 GiB free; free guest build space" >&2; failed=1; };; esac
      if [ "$name" = combined ]; then
        for path in "${SEATD_SRC:-$PWD/../tinyland}" "$PWD/../doas-rs" "${LIBUDEV_ZERO_SRC:-$HOME/d/libudev-zero}" .work/dl/alpine-minirootfs-3.20.3-x86_64.tar.gz .work/guest-root/lib/modules .work/vmlinuz-virt .work/initramfs-virt; do
          [ -e "$path" ] || { echo "$name: missing $path; prepare guest and sibling checkouts" >&2; failed=1; }
        done
        reference=${LIBUDEV_ZERO_SRC:-$HOME/d/libudev-zero}
        if [ -d "$reference" ] && [ "$(git -C "$reference" rev-parse HEAD 2>/dev/null || :)" != 8f1d3d0624496f1c4967f18d6afaddbd552d8bce ]; then
          echo "$name: libudev-zero revision differs; check out the pinned revision" >&2; failed=1
        fi
        for repo in "$PWD" "${SEATD_SRC:-$PWD/../tinyland}" "$PWD/../doas-rs"; do
          if [ -d "$repo" ] && [ -n "$(git -C "$repo" status --porcelain 2>/dev/null)" ]; then echo "$name: dirty checkout $repo; commit changes before qualification" >&2; failed=1; fi
        done
      fi ;;
  esac
done
[ "$failed" -eq 0 ] || exit 1
printf 'preflight: OK; host timing readiness is not established\n'
[ "$mode" = check ] && exit 0
mkdir -p .work/bench
run=$(mktemp -d ".work/bench/$(date -u +%Y%m%dT%H%M%SZ).XXXXXX")
printf 'run: %s\n' "$run"
printf 'commit: %s\n' "$(git rev-parse HEAD)" > "$run/summary.txt"
printf 'dirty: %s\n' "$(git status --porcelain | wc -l | tr -d ' ')" >> "$run/summary.txt"
printf '%s' "$excluded" | while IFS= read -r line; do [ -z "$line" ] || printf 'excluded: %s\n' "$line"; done >> "$run/summary.txt"
status=0
while IFS='|' read -r name level area purpose cost requirements command; do
  case " $selected " in *" $name "*)
    start=$(date +%s)
    if sh -c "$command" > "$run/$name.log" 2>&1; then result=0; else result=$?; status=1; fi
    end=$(date +%s)
    validity='not timed'
    case $name in parse|handle|measure)
      validity='inconclusive (host readiness changed or comparison absent)'
      if ! perf-gate-ready -1; then status=1; fi ;;
    esac
    printf '%s: exit=%s duration=%ss timing=%s; completion is not a timing verdict\n' "$name" "$result" "$((end-start))" "$validity" | tee -a "$run/summary.txt"
    ;;
  esac
done <<EOF_REGISTRY
$registry
EOF_REGISTRY
exit "$status"
