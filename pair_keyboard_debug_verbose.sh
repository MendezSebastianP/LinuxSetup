#!/usr/bin/env bash
set -euo pipefail

KEYBOARD_NAME="Keychron K8 HE"
SCAN_TIME=10
LOGFILE=$(mktemp /tmp/bt-XXXXX.log)

echo "=============================="
echo "DEBUG: bluetoothctl show"
echo "=============================="
bluetoothctl show 2>&1 | tee -a "$LOGFILE"
echo

echo "=============================="
echo "DEBUG: bluetoothctl list controllers"
echo "=============================="
bluetoothctl list 2>&1 | tee -a "$LOGFILE"
echo

echo "=============================="
echo "DEBUG: Starting scan for $SCAN_TIME seconds…"
echo "=============================="

{
  echo scan on
  sleep "$SCAN_TIME"
  echo scan off
  # give it a moment to report “Discovery stopped”
  sleep 1
  echo devices
  echo exit
} | bluetoothctl 2>&1 | tee -a "$LOGFILE"

echo
echo "=============================="
echo "DEBUG: Raw scan log at $LOGFILE"
echo "=============================="
cat "$LOGFILE"
echo

echo "=============================="
echo "DEBUG: Lines containing '$KEYBOARD_NAME'"
echo "=============================="
grep --color=always "$KEYBOARD_NAME" "$LOGFILE" || echo "(none)"
echo

echo "=============================="
echo "DEBUG: Lines with New Device"
echo "=============================="
grep --color=always "^New Device" "$LOGFILE" || echo "(none)"
echo

exit 0
