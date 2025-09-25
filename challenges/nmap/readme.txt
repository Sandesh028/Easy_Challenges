Nmap Challenges
ss -ltnp | egrep ':(8081|2121)\s'
# or
netstat -tlnp | egrep ':(8081|2121)\s'

1) Basic Port Discovery
Task: Discover the hidden network service running on a non-standard port on this host and retrieve the flag that is exposed by that service. When you find the flag, save it as plain text in a file named FLAG.txt inside this directory.

2) Service & Version Detection
Task: Identify a service that exposes version/banner information and extract the flag from that banner/version string. When you find the flag, save it as plain text in a file named FLAG.txt inside this directory.
