#!/usr/bin/env bash
# start_nmap_services.sh
# Simple one-command starter to bring up two nmap-challenge banner servers
# (HTTP banner on 8081 and fake FTP banner on 2121).
# Usage: chmod +x start_nmap_services.sh && ./start_nmap_services.sh

set -euo pipefail

# Directory where challenges live (will respect HOME if set)
BASE_DIR="${HOME:-/root}/challenges"
NMAP_DIR="$BASE_DIR/nmap"
LOG_DIR="${HOME:-/root}/nmap_logs"

mkdir -p "$NMAP_DIR"
mkdir -p "$LOG_DIR"

HTTP_PIDFILE="$NMAP_DIR/nmap_http.pid"
FTP_PIDFILE="$NMAP_DIR/nmap_ftp.pid"

# helper: check if PID is running
is_running() {
  local pid="$1"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

# Write HTTP banner server
cat > "$NMAP_DIR/nmap_http_banner.py" <<'PY'
#!/usr/bin/env python3
import socket, sys
port = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", port))
s.listen(5)
banner = "SimpleHTTP/1.0 (FIT{NMAP_DISCOVERY})\r\n"
print("[nmap_http_banner] listening on", port)
while True:
    conn, addr = s.accept()
    try:
        conn.sendall(banner.encode())
        resp = b"HTTP/1.0 200 OK\r\nContent-Length: 11\r\n\r\nHello world"
        conn.sendall(resp)
    except Exception:
        pass
    finally:
        conn.close()
PY
chmod +x "$NMAP_DIR/nmap_http_banner.py"

# Write fake FTP banner server
cat > "$NMAP_DIR/nmap_fake_ftp.py" <<'PY'
#!/usr/bin/env python3
import socket, sys, time
port = int(sys.argv[1]) if len(sys.argv) > 1 else 2121
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", port))
s.listen(5)
banner = "220 FakeFTP Server v3.2 - FIT{FTP_FLAG}\r\n"
print("[nmap_fake_ftp] listening on", port)
while True:
    conn, addr = s.accept()
    try:
        conn.sendall(banner.encode())
        # optionally read client input (safe pause)
        time.sleep(0.1)
    except Exception:
        pass
    finally:
        conn.close()
PY
chmod +x "$NMAP_DIR/nmap_fake_ftp.py"

# Require python3
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 not found inside container. Install python3, then run this script again."
  exit 1
fi

# Start HTTP server if not already running
if [ -f "$HTTP_PIDFILE" ] && is_running "$(cat "$HTTP_PIDFILE" 2>/dev/null || true)"; then
  echo "HTTP server already running (pid $(cat "$HTTP_PIDFILE"))."
else
  nohup python3 "$NMAP_DIR/nmap_http_banner.py" 8081 > "$LOG_DIR/nmap_http.log" 2>&1 &
  echo $! > "$HTTP_PIDFILE"
  sleep 0.1
  echo "[+] Started HTTP banner server on port 8081 (pid $(cat "$HTTP_PIDFILE")). Log: $LOG_DIR/nmap_http.log"
fi

# Start FTP banner server if not already running
if [ -f "$FTP_PIDFILE" ] && is_running "$(cat "$FTP_PIDFILE" 2>/dev/null || true)"; then
  echo "FTP server already running (pid $(cat "$FTP_PIDFILE"))."
else
  nohup python3 "$NMAP_DIR/nmap_fake_ftp.py" 2121 > "$LOG_DIR/nmap_ftp.log" 2>&1 &
  echo $! > "$FTP_PIDFILE"
  sleep 0.1
  echo "[+] Started fake FTP banner server on port 2121 (pid $(cat "$FTP_PIDFILE")). Log: $LOG_DIR/nmap_ftp.log"
fi

# Print quick verification and stop instructions
echo
echo "To stop the servers:"
echo "  if [ -f \"$HTTP_PIDFILE\" ]; then kill \$(cat \"$HTTP_PIDFILE\") && rm -f \"$HTTP_PIDFILE\"; fi"
echo "  if [ -f \"$FTP_PIDFILE\" ]; then kill \$(cat \"$FTP_PIDFILE\") && rm -f \"$FTP_PIDFILE\"; fi"
echo
echo "Students: after starting the services, git clone the challenges repo as instructed in the container welcome.txt:"
echo "  git clone https://github.com/Sandesh028/Easy_Challenges.git"
echo
echo "Done."
