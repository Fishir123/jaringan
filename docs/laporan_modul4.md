# Laporan Modul 4 — Networking Deep Dive: IP Addressing, Routing, Packet Analysis

Workshop Administrasi Jaringan · PENS — Teknik Informatika dan Komputer

- Kelompok: X = 2 · srv01 difungsikan sebagai **router internal**
- OS: Debian 13.4 (trixie) · Tanggal: 2026-06-12
- LAN-A: 10.10.2.0/24 (vboxnet0) · LAN-B: 10.20.2.0/24 (vboxnet1)

## 1. Ringkasan

srv01 dijadikan router antara dua subnet. cli01 dipindah ke LAN-B,
IP forwarding diaktifkan di srv01, dan adm01 (LAN-A) diberi static route ke
LAN-B. Komunikasi lintas subnet diuji dan dianalisis dengan tcpdump (ICMP & TCP
handshake).

## 2. Topologi & IP Plan

| Host  | Interface | IP            | Subnet | Gateway    |
|-------|-----------|---------------|--------|------------|
| srv01 | enp0s8    | 10.10.2.11/24 | LAN-A  | - (router) |
| srv01 | enp0s9    | 10.20.2.1/24  | LAN-B  | - (router) |
| adm01 | enp0s8    | 10.10.2.10/24 | LAN-A  | route ke B |
| cli01 | enp0s8    | 10.20.2.2/24  | LAN-B  | 10.20.2.1  |

Diagram & logic lengkap: `docs/routing_design_v1.md`.

## 3. Routing & IP Forwarding (4)

- srv01 NIC3 ditambahkan (host-only vboxnet1), enp0s9 = 10.20.2.1/24.
- IP forwarding permanen: `/etc/sysctl.d/99-router.conf` → `net.ipv4.ip_forward=1`
  (terverifikasi `/proc/sys/net/ipv4/ip_forward = 1`).
- cli01 pindah ke LAN-B (10.20.2.2) dengan gateway srv01.

Evidence: `evidence/ip_forward_check.txt`, `evidence/route_table_srv01.txt`.

## 4. Static Route di adm01 (5)

```
sudo ip route add 10.20.2.0/24 via 10.10.2.11
```
Dibuat persisten via `post-up` di `/etc/network/interfaces.d/lan0`.
Uji: `ping 10.20.2.2` dari adm01 → **0% loss, TTL=63** (lewat 1 hop router srv01).

## 5. Packet Analysis dengan tcpdump (6 & 7)

**ICMP** (`tcpdump -i enp0s8 -n icmp`): terlihat echo request 10.10.2.10 →
10.20.2.2 dan echo reply sebaliknya, lengkap dengan source/destination IP.

**TCP handshake** (`tcpdump -i any -n tcp port 22 and host 10.20.2.2`):
```
Flags [S]   = SYN
Flags [S.]  = SYN-ACK
Flags [.]   = ACK
```
Capture juga menunjukkan srv01 me-route: paket masuk enp0s8, keluar enp0s9.

Evidence: `evidence/tcpdump_icmp.txt`, `evidence/tcpdump_ssh.txt`.
Analisis (ARP, ICMP vs TCP, SYN, TTL): `docs/packet_analysis_notes.md`.

## 6. Troubleshooting Terstruktur (9)

Urutan diagnosa yang dipakai: cek IP (`ip a`) → route (`ip r`) → gateway →
forwarding (`/proc/.../ip_forward`) → firewall → capture tcpdump.
Tidak menebak firewall lebih dulu.

## 7. Definition of Done (Checklist)

| Item | Status |
|------|--------|
| adm01 ↔ cli01 beda subnet bisa ping | OK (TTL=63) |
| tcpdump menunjukkan ICMP | OK |
| tcpdump menunjukkan TCP handshake | OK (SYN/SYN-ACK/ACK) |
| Routing terdokumentasi jelas | OK |
| Alur paket source→destination dipahami | OK |

## 8. Bukti Screenshot

### [1] srv01 sebagai router (2 subnet + ip_forward=1 + routing table)
![srv01 router](/home/faiqm/Documents/jaringan/modul4/bukti_1_srv01_router.png)

### [2] adm01 → cli01 lintas subnet (TTL=63 = via router)
![adm01 ping](/home/faiqm/Documents/jaringan/modul4/bukti_2_adm01_ping.png)

### [3] tcpdump ICMP (echo request/reply)
![tcpdump icmp](/home/faiqm/Documents/jaringan/modul4/bukti_3_tcpdump_icmp.png)

### [4] tcpdump TCP handshake (SYN / SYN-ACK / ACK)
![tcpdump tcp](/home/faiqm/Documents/jaringan/modul4/bukti_4_tcpdump_tcp.png)

## 9. Penyimpangan dari Modul

- OS Debian 13 (trixie), bukan Debian 12.
- Konfigurasi jaringan via **ifupdown** (bukan nmcli) sesuai instalasi aktual;
  hasil akhir (IP statik, gateway, route) sama.
- User admin `fishir` menggantikan `student`.
