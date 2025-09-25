#!/usr/bin/env python3
import socket, sys
port = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", port))
s.listen(5)
banner = "SimpleHTTP/1.0 (FIT{NMAP_FLAG})\r\n"
print("[+] Nmap banner server listening on", port)
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
