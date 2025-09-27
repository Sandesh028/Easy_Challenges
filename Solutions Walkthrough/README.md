
# Easy_Challenges — Solutions

> **Warning:** This file contains full solutions and flags. 

---

## Quick prerequisites / environment

Assumes challenge files are present in a `challenges/` directory at repo root:
```
challenges/
  nmap/
  pcap/
  crypto/
  osint/
```

If you run the challenges inside a Docker container, it's recommended to add network capabilities for tools like `nmap`:

```bash
docker run -it --rm \
  --cap-add=NET_RAW --cap-add=NET_ADMIN \
  -p 8081:8081 -p 2121:2121 \
  <your-ctf-image-name>
```

Inside the container, clone the repo and prepare challenges:

```bash
git clone https://github.com/Sandesh028/Easy_Challenges.git
cd Easy_Challenges
sudo ./setup.sh     # creates artifacts and starts servers
# or, to only start nmap servers:
./setup.sh 
```

---

# Solutions

> Each challenge section lists **student commands** (how students should solve).

---

## NMAP challenges (2)

Files: `challenges/nmap/nmap_http_banner.py`, `challenges/nmap/nmap_fake_ftp.py`

### 1) Basic port discovery (port 8081)
**Student commands:**
```bash
nmap -p- 127.0.0.1
nmap -sV -p8081 127.0.0.1
nc 127.0.0.1 8081
```

**Output flag:**
Connecting with `nc 127.0.0.1 8081` shows:
```
SimpleHTTP/1.0 (FIT{NMAP_DISCOVERY})
```
**Flag:** `FIT{NMAP_DISCOVERY}`

---

### 2) Service & Version Detection (port 2121)
**Student commands:**
```bash
nmap -sV -p2121 127.0.0.1
nc 127.0.0.1 2121
```

**Output flag:**
`nc 127.0.0.1 2121` shows:
```
220 FakeFTP Server v3.2 - FIT{FTP_FLAG}
```
**Flag:** `FIT{FTP_FLAG}`

---

## PCAP challenges (2)

Files: `challenges/pcap/http_creds.pcap`, `challenges/pcap/dns_exfil.pcap`

### 1) HTTP credentials (POST)
**Student commands:**
```bash
strings challenges/pcap/http_creds.pcap | grep FIT
tshark -r challenges/pcap/http_creds.pcap -Y 'http.request' -T fields -e http.file_data -e http.request
```

**Output flag:**
`strings` reveals:
```
username=ctf&password=FIT{HTTP_FLAG}
```
**Flag:** `FIT{HTTP_FLAG}`

---

### 2) DNS exfiltration
**Student commands:**
```bash
tshark -r challenges/pcap/dns_exfil.pcap -T fields -e dns.qry.name
tshark -r challenges/pcap/dns_exfil.pcap -Y dns -V | less
```

**Output flag:**
`tshark` output includes:
```
FIT-DNS-EXFIL.example.com
```
**Flag:** `FIT{DNS_EXFIL}`

---

## Crypto challenges (2)

Files: `challenges/crypto/Unknown_Enc.txt`, `challenges/crypto/Horse.txt` (or `morse.txt`)

### 1) Unknown encryption (ROT8000)
**File contents:**
```
籏籒籝粄簪籨籖簪簭簭籨籬簪籹簬簼类粆
```

**Goal:** reverse the ROT8000-style transformation to ASCII.

**Python solution:**
```
1. GO to dcode website: https://www.dcode.fr/cipher-identifier
2. Copy paste the given encrypted text here in identifer and if it tell you which is the cipher used: https://www.dcode.fr/rot8000-cipher
3. Paste the text here and click on decode and you will get the flag.

```

**Output flag:**
Decoded output:
```
FIT{!_M!$$_c!p#3r}
```
**Flag:** `FIT{!_M!$$_c!p#3r}`

---

### 2) Horse / Morse code
**Student commands / approach:**
- If file is Horse-like: decode using a simple Python mapping or an online Morse decoder.
- Example snippet:
```
..-. .. - / -- --- .-. ... . ..--.- ..- ..--.- --- -.- .- -.-- / 
```
**Expected flag:** 
`FIT MORSE_U_OKAY` OR `FIT{MORSE_U_OKAY}` is Correct!!!
---

## OSINT challenges (2)

Files: `challenges/osint/sample.pdf`, `challenges/osint/image_link.txt`

### 1) PDF metadata
**Student commands:**
```bash
exiftool challenges/osint/sample.pdf
pdfinfo challenges/osint/sample.pdf
strings challenges/osint/sample.pdf | grep FIT
```

**Output flag:**
`exiftool` shows:
```
Producer : FIT{PDF_META}
```
**Flag:** `FIT{PDF_META}`

---

### 2) Image recognition
**Student commands:**
```bash
cat challenges/osint/image_link.txt
# download the image
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=10IdqK8J8z-tboTNkU2GoX64kwuarlmze' -O /tmp/building.jpg
# view the image and use google image search or yandex search engine to search about the image:

```
 **Expected answer:**  
`Colorado Convention Center`


### 3) Bonus Image recognition
**Student commands:**
```bash
See the image named as "meetup.jpeg" on the github link or the Bonus challenge folder on the github repo:
https://github.com/Sandesh028/Easy_Challenges.git
# view the image and use google image search or yandex search engine to search about the image:

```
 **Expected answer:**  
`Seal Point Park, CA`

---

