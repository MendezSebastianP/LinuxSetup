#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ───────────────────────────────────────────────
KEYBOARD_NAME="Keychron K8 HE"   # exact substring in the device’s name
SCAN_TIME=5                      # seconds to scan
# ───────────────────────────────────────────────────────────

echo
echo "[1] Powering on adapter…"
bluetoothctl power on >/dev/null

echo
echo "[2] Scanning for $KEYBOARD_NAME for $SCAN_TIME seconds…"
# Run a scan, then list cached devices, all in one session
SCAN_AND_LIST=$(
  {
    echo "scan on"
    sleep "$SCAN_TIME"
    echo "scan off"
    # give BlueZ a moment to update its cache
    sleep 1
    echo "devices"
    echo "quit"
  } | bluetoothctl 2>/dev/null
)

echo
echo "[3] Raw scan & device list:"
echo "$SCAN_AND_LIST"
echo

echo "[4] Filtering for lines containing “$KEYBOARD_NAME”:"
MATCHES=$(echo "$SCAN_AND_LIST" | grep --ignore-case "$KEYBOARD_NAME" || true)
if [[ -z "$MATCHES" ]]; then
  echo "   → No devices matched “$KEYBOARD_NAME”."
  echo "     • Make sure it’s in pairing mode (hold Fn+1 until LEDs blink)."
  exit 1
fi
echo "$MATCHES"
echo

echo "[5] Extracting the first MAC from those lines…"
MAC=$(echo "$MATCHES" \
      | grep -oE '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}' \
      | head -n1)
if [[ -z "$MAC" ]]; then
  echo "   → Failed to parse a MAC address."
  exit 1
fi
echo "   → Using MAC: $MAC"
echo

echo "[6] Pairing & trusting (in batch)…"
bluetoothctl <<EOF
pair   $MAC
trust  $MAC
quit
EOF
echo

echo "[7] Connecting now as a fresh command…"
bluetoothctl connect "$MAC"
echo

echo "[8] Verifying connection (up to 10 s)…"
for i in {1..10}; do
  sleep 1
  if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
    echo "✅  Success! Your Keychron is connected."
    exit 0
  fi
done

echo "❌  Still not connected after 10 s."
echo "   • Try changing your K8’s channel (Fn+1/2/3) and rerun."
echo "   • Or run:  bluetoothctl connect $MAC"
exit 1
