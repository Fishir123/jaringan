# Security Hardening Policy v1 (Modul 10)

srv01 · Workshop Administrasi Jaringan PENS · Kelompok X=2

## 1. Konteks

srv01 adalah node multi-fungsi: router antar-subnet (Modul 4), DNS authoritative
(Modul 5), DHCP server (Modul 5), dan web server HTTP/HTTPS + reverse proxy
(Modul 6). Hardening firewall harus menerapkan default-deny tanpa memutus
layanan yang sudah berjalan.

## 2. Prinsip

- Default policy DROP pada chain `input` dan `forward`; `output` accept.
- Hanya port layanan yang benar-benar dipakai yang dibuka (least exposure).
- Stateful: `ct state established,related accept`, `ct state invalid drop`.
- Loopback selalu diizinkan.
- Paket yang ditolak di-log (rate-limited) untuk audit.
- Proteksi brute-force SSH dengan fail2ban.

## 3. Port yang dibuka di srv01 (chain input)

| Port/Proto | Layanan | Modul asal | Alasan |
|-----------|---------|-----------|--------|
| 22/tcp | SSH | Modul 1 | Administrasi |
| 53/tcp, 53/udp | DNS (bind9) | Modul 5 | Resolusi nama lab2.local |
| 67/udp | DHCP server | Modul 5 | Lease IP klien LAN-B |
| 80/tcp | HTTP (nginx) | Modul 6 | Web + redirect |
| 443/tcp | HTTPS (nginx) | Modul 6 | Web TLS internal |
| ICMP / ICMPv6 | ping | Modul 4 | Diagnosa konektivitas |

Port yang TIDAK dibuka (sengaja): 3306 (MariaDB ada di adm01, bukan srv01),
9000 (backend python bind 127.0.0.1 saja - defense in depth), 953 (rndc lokal).

## 4. Chain forward (router)

srv01 me-route LAN-A (10.10.2.0/24) ↔ LAN-B (10.20.2.0/24) ↔ NAT. Default drop,
lalu izinkan trafik established + trafik keluar dari interface internal. Tanpa
ini fungsi router Modul 4 mati.

## 5. fail2ban (anti brute-force SSH)

- Jail `[sshd]`, backend `systemd` (Debian 13 mengirim log sshd ke journald).
- `maxretry=3`, `findtime=600s`, `bantime=600s`.
- Aksi ban menambahkan IP ke set nft `f2b-table` (drop).
- `ignoreip` = loopback.

## 6. Persistensi

`systemctl enable nftables fail2ban` → ruleset & jail aktif otomatis saat boot.
Ruleset disimpan di `/etc/nftables.conf`.

## 7. Penyimpangan dari modul

- Ruleset modul (hanya 22, 80, ICMP) diperluas untuk 53/67/443 + chain forward,
  karena srv01 menjalankan DNS, DHCP, HTTPS, dan routing. Memakai ruleset modul
  apa adanya akan mematikan seluruh lab (DNS/DHCP/HTTPS/routing down).
- OS Debian 13 (trixie); fail2ban backend `systemd` (bukan file
  `/var/log/auth.log`) karena Debian 13 default journald.
- nftables v1.1.3 (sintaks `ct state`, set inline `{80,443}`).
