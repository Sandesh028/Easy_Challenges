#!/usr/bin/env bash
set -euo pipefail

# stop_nmap.sh
# Stops the nmap challenge servers started by start_nmap.sh
# Usage: ./stop_nmap.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NMAP_DIR="$SCRIPT_DIR/challenges/nmap"
PIDFILE="$NMAP_DIR/pids.txt"

if [ ! -f "$PIDFILE" ]; then
  echo "No pidfile found at $PIDFILE — nothing to stop."
  exit 0
fi

echo "[*] Stopping PIDs from $PIDFILE ..."
while read -r pid; do
  # ensure it's numeric
  case "$pid" in
    ''|*[!0-9]*)
      echo "Skipping invalid PID entry: $pid"
      continue
      ;;
    *)
      if kill -0 "$pid" 2>/dev/null; then
        kill "$pid" && echo "Killed $pid"
      else
        echo "PID $pid not running"
      fi
      ;;
  esac
done < "$PIDFILE"

rm -f "$PIDFILE"
echo "[+] Done. Servers stopped."
