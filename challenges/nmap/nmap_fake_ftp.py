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
        # optionally read client input (safe timeout)
        time.sleep(0.1)
    except Exception:
        pass
    finally:
        conn.close()
