#!/usr/bin/env bash
set -euo pipefail

# start_nmap.sh
# Starts the two nmap challenge servers (HTTP banner and fake FTP).
# Usage: ./start_nmap.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NMAP_DIR="$SCRIPT_DIR/challenges/nmap"
LOGDIR="$NMAP_DIR/logs"
PIDFILE="$NMAP_DIR/pids.txt"

# Ensure challenge scripts exist
if [ ! -d "$NMAP_DIR" ]; then
  echo "ERROR: expected challenges at: $NMAP_DIR"
  exit 1
fi

if [ ! -f "$NMAP_DIR/nmap_server.py" ] && [ ! -f "$NMAP_DIR/nmap_http_banner.py" ]; then
  echo "ERROR: can't find http banner server script in $NMAP_DIR"
  exit 1
fi
if [ ! -f "$NMAP_DIR/nmap_fake_ftp.py" ]; then
  echo "ERROR: can't find fake FTP server script in $NMAP_DIR"
  exit 1
fi

# Prevent duplicate runs
if [ -f "$PIDFILE" ]; then
  echo "It looks like the servers were already started (found $PIDFILE)."
  echo "If you want to restart, run ./stop_nmap.sh first, or remove $PIDFILE."
  echo "Current $PIDFILE contents:"
  cat "$PIDFILE" || true
  exit 0
fi

mkdir -p "$LOGDIR"

echo "[*] Starting nmap challenge servers..."
# Start HTTP banner server (prefer nmap_server.py; fallback to nmap_http_banner.py)
if [ -f "$NMAP_DIR/nmap_server.py" ]; then
  nohup python3 "$NMAP_DIR/nmap_server.py" 8081 > "$LOGDIR/http.log" 2>&1 &
  echo $! >> "$PIDFILE"
else
  nohup python3 "$NMAP_DIR/nmap_http_banner.py" 8081 > "$LOGDIR/http.log" 2>&1 &
  echo $! >> "$PIDFILE"
fi

# Start fake FTP banner server
nohup python3 "$NMAP_DIR/nmap_fake_ftp.py" 2121 > "$LOGDIR/ftp.log" 2>&1 &
echo $! >> "$PIDFILE"

sleep 0.3

echo "[+] Started. PIDs written to $PIDFILE"
echo "Logs: $LOGDIR/http.log , $LOGDIR/ftp.log"
echo
# Show listeners (best-effort - try ss then netstat)
if command -v ss >/dev/null 2>&1; then
  ss -ltnp | egrep ':(8081|2121)\s'
elif command -v netstat >/dev/null 2>&1; then
  netstat -tlnp | egrep ':(8081|2121)\s'
else
  echo "Tip: run 'ss -ltnp' or 'netstat -tlnp' to verify listeners."
fi

echo
echo "To stop: ./stop_nmap.sh"
