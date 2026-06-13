# Laporan Modul 10 — Security Hardening, Firewall & Audit Dasar

Workshop Administrasi Jaringan · PENS — Teknik Informatika dan Komputer
Kelompok X = 2 · Tanggal: 2026-06-14 · OS: Debian 13.4 (trixie)

## 1. Tujuan

Mengamankan server Linux dasar, mengonfigurasi firewall (nftables), melakukan
audit service & port, dan mendeteksi brute-force SSH (fail2ban).

## 2. Topologi

```
Internet (NAT enp0s3) ── srv01 (Firewall + Server) ── LAN-B 10.20.2.0/24 ── cli01
                          DNS+DHCP+Web+Router            (10.20.2.10)
                          10.20.2.1
```

## 3. Package

`nftables`, `fail2ban`, `nmap`, `net-tools`, `curl`, `vim` terpasang di srv01.
nftables v1.1.3 · Fail2Ban v1.1.0 · Nmap 7.95.

## 4. Firewall (nftables)

File `/etc/nftables.conf`. Chain `input` policy **drop**, hanya membuka port
layanan lab. Chain `forward` policy **drop** + izin routing antar subnet
(fungsi router Modul 4). `output` accept. Stateful + log paket ditolak.

| Port | Layanan | Status |
|------|---------|--------|
| 22/tcp | SSH | open |
| 53 tcp+udp | DNS | open |
| 67/udp | DHCP | open |
| 80, 443/tcp | HTTP/HTTPS | open |
| ICMP | ping | accept |

Apply: `nft -f /etc/nftables.conf`; `systemctl enable nftables` (persist boot).

Penting: ruleset modul (hanya 22/80/ICMP) sengaja diperluas. srv01 menjalankan
DNS, DHCP, HTTPS, dan routing — memakai ruleset minimal modul akan mematikan
seluruh layanan lab. Lihat `docs/hardening_policy_v1.md`.

## 5. fail2ban

Jail `[sshd]`: `maxretry=3`, `findtime=600`, `bantime=600`, backend `systemd`.
File `/etc/fail2ban/jail.local`.

## 6. Pengujian

### a. Audit port (srv01)
`ss -tulnp` → layanan terdaftar: 22, 53, 67, 80, 443 (sesuai kebijakan).
Evidence: `evidence/audit_ports.txt`.

### b. Verifikasi layanan tetap hidup (dari cli01)
DNS `dig app.lab2.local @10.20.2.1` → 10.20.2.1; HTTP 200; HTTPS 200; ping OK;
SSH 22 open; DHCP lease aktif (10.20.2.10). Firewall tidak memutus layanan.

### c. Scan nmap (cli01 → srv01)
22/53/80/443 = open; 3306/8080/9000 = **filtered** (di-drop policy). Membuktikan
firewall menyaring port yang tidak diizinkan.
Evidence: `evidence/nmap_scan.txt`.

### d. Brute-force SSH
4x login gagal dari cli01 → fail2ban mendeteksi (Total failed: 4) dan
**ban IP 10.20.2.10** (Total banned: 1). Setelah bukti diambil, IP di-unban agar
klien tetap dipakai. Evidence: `evidence/fail2ban_status.txt`.

## 7. Penjelasan port yang terbuka

- 22 SSH: administrasi (publickey-only, hasil hardening Modul 1).
- 53 DNS: zona authoritative lab2.local + reverse (Modul 5).
- 67 DHCP: distribusi IP klien LAN-B (Modul 5).
- 80/443 HTTP/HTTPS: web server + reverse proxy TLS internal (Modul 6).
- Port lain (mis. 3306 MariaDB, 9000 backend) ditolak/tidak diekspos → backend
  python hanya bind 127.0.0.1, DB ada di host lain (adm01).

## 8. Bukti Screenshot

### [1] nftables aktif (policy drop) + fail2ban (ban brute-force) — srv01
![firewall](/home/faiqm/Documents/jaringan/modul10/bukti_1_firewall_fail2ban.png)

### [2] Audit nmap dari cli01 — port allowed=open, lainnya=filtered
![nmap](/home/faiqm/Documents/jaringan/modul10/bukti_2_nmap_audit.png)

## 9. Kesimpulan

Firewall nftables default-deny + fail2ban memberi hardening dan proteksi
brute-force, sementara seluruh layanan lab (DNS, DHCP, web, routing) tetap
berfungsi. Audit `ss` dan `nmap` mengonfirmasi hanya port yang diizinkan yang
terbuka. *Server yang berjalan ≠ server yang aman* — keamanan butuh kontrol
akses eksplisit, bukan sekadar layanan hidup.

## 10. Penyimpangan

- OS Debian 13 (bukan 12); fail2ban backend `systemd` (journald).
- Ruleset diperluas dari modul untuk menjaga DNS/DHCP/HTTPS/routing.
- nmap dijalankan dari cli01 (modul menyebut srv01) agar benar-benar menguji
  firewall dari sisi klien eksternal.
