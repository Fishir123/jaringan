# Laporan Modul 1 — Kickoff Peran SysAdmin & Setup Lab

Workshop Administrasi Jaringan · PENS — Teknik Informatika dan Komputer

- Skenario PBL: Opsi A — WSN/IoT Lab Kampus
- Nomor kelompok: X = 2 → LAN `10.10.2.0/24`, domain draft `lab2.local`
- Tanggal: 2026-06-11
- User admin: `fishir` (grup sudo)

## 1. Ringkasan

Tiga VM Debian (adm01, srv01, cli01) disiapkan di VirtualBox dengan dua NIC
(NAT + Host-only), IP statik LAN, SSH key-based dari adm01, dan baseline
hardening pada srv01 & cli01. Seluruh artefak PBL (inventory, policy blueprint,
topology, change log, evidence) disimpan dalam repo git `lab-admin/`.

## 2. Topologi & Addressing

| Host  | Role              | LAN IP (enp0s8) | NAT (enp0s3) | OS         |
|-------|-------------------|-----------------|--------------|------------|
| adm01 | admin workstation | 10.10.2.10/24   | DHCP 10.0.2.15 | Debian 13.4 |
| srv01 | server inti       | 10.10.2.11/24   | DHCP 10.0.2.15 | Debian 13.4 |
| cli01 | client uji        | 10.10.2.12/24   | DHCP 10.0.2.15 | Debian 13.4 |

Host-only `vboxnet0`: host 10.10.2.1/24, DHCP dimatikan.
Adapter per VM: NIC1 = NAT (apt/internet), NIC2 = Host-only (LAN internal).

## 3. Langkah Kerja yang Dilakukan

1. Host: set `vboxnet0` ke 10.10.2.1/24, matikan DHCP host-only, izinkan
   rentang 10.10.0.0/16 via `/etc/vbox/networks.conf`.
2. Tiap VM: ganti `/etc/apt/sources.list` dari cdrom ke repo online trixie
   (cdrom memblok `apt update`).
3. Tiap VM: `apt update` lalu install `openssh-server git vim curl wget
   net-tools dnsutils`, enable service ssh.
4. Tiap VM: set IP statik LAN enp0s8 via `/etc/network/interfaces.d/lan0`.
5. adm01: generate SSH key ed25519, pasang pubkey ke srv01 & cli01.
6. srv01 & cli01: hardening sshd via drop-in `99-hardening.conf`.

## 4. Konfigurasi Keamanan SSH

Key admin (adm01): ED25519, `SHA256:BwwjayIXG85d9USc87tXtybsWOe8TxMeYOgo8tEOLDI`, comment `adm01@lab2`.

Drop-in `/etc/ssh/sshd_config.d/99-hardening.conf` di srv01 & cli01:

```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Hardening diterapkan SETELAH key login terverifikasi → tidak terjadi lockout
(change control terjaga).

## 5. Hasil Verifikasi (Definition of Done)

| Item | Hasil |
|------|-------|
| 3 VM running, 2 NIC per VM | OK |
| IP statik LAN benar (.10/.11/.12) | OK |
| Ping LAN antar VM | OK, 0% packet loss |
| adm01 SSH key → srv01 tanpa password | OK (hostname=srv01) |
| adm01 SSH key → cli01 tanpa password | OK (hostname=cli01) |
| Root login off, password auth off | OK (password → `Permission denied (publickey)`) |
| Tidak terkunci sendiri | OK (key login tetap jalan) |
| Inventory + policy blueprint v0 | Ada |
| Evidence tersimpan | Ada (ping/ssh/ip a) |
| Change log ≥ 3 perubahan + alasan | Ada (6 entri) |

Bukti lengkap: `evidence/ping_tests.txt`, `evidence/ssh_tests.txt`, `evidence/ip_a_all.txt`.

## 6. Penyimpangan dari Modul (dengan alasan)

- OS Debian 13 (trixie), bukan Debian 12 — mengikuti ISO yang tersedia.
- Network manager ifupdown (`/etc/network/interfaces.d/lan0`), bukan
  NetworkManager/nmcli — adaptasi ke kondisi instalasi. Hasil akhir (IP statik LAN) identik.

## 7. Catatan Operasional

- NAT port-forward sementara dibuat untuk otomasi setup: host
  `2210/2211/2212` → guest `22` (adm01/srv01/cli01). Bisa dihapus jika tidak diperlukan.
- Repo belum dipush ke remote.

## 8. Bukti Screenshot Konsol VM

Screenshot diambil langsung dari konsol VirtualBox tiap VM dan diverifikasi via OCR.

### adm01 — hostname, IP LAN, ping, SSH key ke srv01 & cli01

![Bukti adm01](/home/faiqm/Documents/jaringan/modul1/bukti_adm01.png)

### srv01 — hostname, IP LAN, hardening sshd, authorized_keys

![Bukti srv01](/home/faiqm/Documents/jaringan/modul1/bukti_srv01.png)

### cli01 — hostname, IP LAN, hardening sshd, authorized_keys

![Bukti cli01](/home/faiqm/Documents/jaringan/modul1/bukti_cli01.png)

## 9. Pemetaan Meta-Principles

| Prinsip | Penerapan |
|---------|-----------|
| Policy-first | Konfigurasi mengikuti policy_blueprint_v0 (naming, IP plan, aturan SSH). |
| Repeatable & verifiable | Langkah terdokumentasi + evidence; bisa diulang dari nol. |
| Minimize privileges | SSH key-only, root login off, akses admin terpusat di adm01. |
| Change control | change_log.md mencatat tiap perubahan + alasan + rollback. |
| Measure & observe | Verifikasi ping/ssh nyata, bukan asumsi. |
| Human systems | Hardening setelah key terverifikasi untuk cegah lockout; dokumentasi jelas. |
