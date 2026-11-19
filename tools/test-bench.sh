#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p .work/tmp
scratch=$(mktemp -d "$PWD/.work/tmp/bench-test.XXXXXX")
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
sh tools/bench.sh --dry-run --tier edit > "$scratch/out"
grep -q '^driver: sh tools/test-bench.sh$' "$scratch/out"
grep -q '^excluded: storm: above tier edit$' "$scratch/out"
sh tools/bench.sh --dry-run --tier change --area engine --skip storm > "$scratch/out"
grep -q '^handle: cargo bench' "$scratch/out"
if grep -q '^storm: cargo bench' "$scratch/out"; then exit 1; fi
for args in '--workload nonsense' '--area nonsense' '--tier edit --workload storm' '--tier change --workload engine'; do
  if sh tools/bench.sh --dry-run $args > "$scratch/out" 2>&1; then echo "unexpected selection: $args" >&2; exit 1; fi
done
before=$(if [ -d .work/bench ]; then ls -a .work/bench; fi)
sh tools/bench.sh --dry-run --tier edit > "$scratch/out"
after=$(if [ -d .work/bench ]; then ls -a .work/bench; fi)
[ "$before" = "$after" ]
mkdir -p "$scratch/bin"
for tool in sh dirname cut grep uname; do ln -s "$(command -v "$tool")" "$scratch/bin/$tool"; done
if PATH="$scratch/bin" sh tools/bench.sh --tier change --workload parse > "$scratch/out" 2>&1; then echo 'missing cargo accepted' >&2; exit 1; fi
grep -q 'missing cargo' "$scratch/out"
[ "$after" = "$(if [ -d .work/bench ]; then ls -a .work/bench; fi)" ]
printf '%s\n' 'bench selection, dry run and preflight tests passed'
