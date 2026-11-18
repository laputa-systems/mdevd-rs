#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
ROOT=$PWD
mkdir -p .work/tmp .work/ref
PIN=8f1d3d0624496f1c4967f18d6afaddbd552d8bce
REF=$ROOT/.work/ref/libudev-zero

if [ -n "${LIBUDEV_ZERO_SRC:-}" ] && [ -d "$LIBUDEV_ZERO_SRC" ]; then
  mkdir -p "$ROOT/.work/ref"
  rm -rf "$REF"
  ln -sfn "$LIBUDEV_ZERO_SRC" "$REF"
  echo "check-udev-consumer: using local LIBUDEV_ZERO_SRC=$LIBUDEV_ZERO_SRC"
elif [ ! -d "$REF" ]; then
  git clone --quiet https://github.com/laputa-systems/libudev-zero "$REF"
fi
if [ -L "$REF" ]; then
  actual=$(cd "$REF" && git rev-parse HEAD)
else
  (cd "$REF" && git fetch --quiet origin && git checkout --quiet "$PIN")
  actual=$(cd "$REF" && git rev-parse HEAD)
fi
if [ "$actual" != "$PIN" ]; then
  echo "check-udev-consumer: pin mismatch: $actual != $PIN" >&2
  exit 1
fi
echo "check-udev-consumer: fork at $PIN"

cc -O2 -Wall -DUSB_IDS_PATH='"/usr/share/hwdata/usb.ids"' -o "$ROOT/.work/ref/consumer" "$ROOT/tools/udev-consumer.c" \
  "$REF/udev.c" "$REF/udev_device.c" "$REF/udev_enumerate.c" "$REF/udev_list.c" "$REF/udev_monitor.c" \
  -I"$REF"
echo "check-udev-consumer: consumer built (unpatched fork API)"
cargo fetch --locked

export CONSUMER_BIN="$ROOT/.work/ref/consumer"
export CONSUMER_OUT="$ROOT/.work/tmp/consumer.out"
rm -f "$CONSUMER_OUT"

run_exchange() {
  test_case=$1
  log=$2
  witness=$3
  if ! unshare -U -n -r cargo test --offline --locked -q --test publish "$test_case" \
    -- --exact --ignored --nocapture > "$log" 2>&1; then
    cat "$log" >&2
    exit 1
  fi
  cat "$log"
  if ! grep -Fq "$witness" "$log"; then
    echo "check-udev-consumer: missing witness for $test_case" >&2
    exit 1
  fi
}

echo "--- Rust multicast self-exchange under unshare:"
run_exchange publish_live_multicast "$ROOT/.work/tmp/live-mcast.log" "live-multicast: exchanged"
echo "--- C consumer exchange under unshare:"
run_exchange publish_live_consumer "$ROOT/.work/tmp/live-consumer.log" "live-consumer: verified"
echo "check-udev-consumer: OK"
