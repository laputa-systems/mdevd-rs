#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
ROOT=$PWD

echo "check-ci-pins: locked deps"
test -f Cargo.lock
tools/check-deps.sh
tools/check-pins.sh

echo "check-ci-pins: toolchain pin"
grep -q 'channel = "nightly-2026-11-09"' rust-toolchain.toml

echo "check-ci-pins: workflow pins are full SHAs"
if rg -n 'uses:\s*[0-9a-f]{40}\s*(#|$)' .github/workflows; then
  echo "check-ci-pins: bare SHA without owner/repo@ found" >&2
  exit 1
fi
if rg -n 'uses:' .github/workflows | grep -v -E 'uses:\s*[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+@[0-9a-f]{40}'; then
  echo "check-ci-pins: workflow pin must be owner/repo@full-SHA" >&2
  exit 1
fi
bad=$(rg -n 'uses:[^#]*@[A-Za-z0-9._/-]+' .github/workflows || true)
echo "$bad"
echo "$bad" | while IFS= read -r line; do
  [ -z "$line" ] && continue
  ref=$(printf '%s' "$line" | sed -n 's/.*@\([A-Za-z0-9._/-]*\).*/\1/p')
  case $ref in
    ????????-????-????-????-????????????) ;;
    *)
      if ! printf '%s' "$ref" | grep -Eq '^[0-9a-f]{40}$'; then
        echo "check-ci-pins: non-SHA pin: $line" >&2
        exit 1
      fi
      ;;
  esac
done
if printf '%s' "$bad" | grep -Eq '@v[0-9]|@main|@master'; then
  echo "check-ci-pins: floating tag pin found" >&2
  exit 1
fi
echo "check-ci-pins: workflow SHAs OK"

echo "check-ci-pins: attribution"
for f in AUTHORS COPYING DCO; do
  test -f "$f" || { echo "check-ci-pins: missing $f" >&2; exit 1; }
done
grep -q 'Laurent Bercot' AUTHORS

echo "check-ci-pins: native-dep verification"
allow="^mdevd v|^libc v"
baddeps=$(cargo tree --offline -e normal --prefix none 2>/dev/null | grep -Ev "$allow" || true)
if [ -n "$baddeps" ]; then
  echo "check-ci-pins: forbidden production dep:" >&2
  echo "$baddeps" >&2
  exit 1
fi
echo "check-ci-pins: production deps OK (libc only)"

echo "check-ci-pins: dead-code removal"
if rg -n 'todo!|unimplemented!|FIX''ME' src/ benches/ 2>/dev/null; then
  echo "check-ci-pins: dead-code marker found" >&2
  exit 1
fi
cargo clippy --locked -q --all-targets
echo "check-ci-pins: clippy clean"

echo "check-ci-pins: explicit panics and expects"
if rg -n 'panic!\(|expect\(' src/ | grep -v test; then
  echo "check-ci-pins: note: explicit panics in src above (must be unreachable paths)" >&2
fi
echo "check-ci-pins: musl artifacts"
for target in x86_64-unknown-linux-musl aarch64-unknown-linux-musl; do
  bin="target/$target/release/mdevd"
  test -x "$bin" || { echo "check-ci-pins: missing $bin (run the C1 musl builds first)" >&2; exit 1; }
  if command -v file >/dev/null 2>&1; then
    file "$bin" | grep -qi 'static' || echo "check-ci-pins: note: $bin not reported static by file(1)"
  fi
done
echo "check-ci-pins: musl binaries present"

echo "check-ci-pins: OK"
