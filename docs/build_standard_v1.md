# Build Standard v1 (srv01 baseline)

Standar membangun server inti yang konsisten dan dapat diulang.

## 1. Baseline paket minimum (server)
```
vim git curl wget          # editor, VCS, transfer
dnsutils net-tools          # diagnosa DNS & jaringan
rsyslog logrotate           # logging & rotasi
htop tree                   # observasi proses & struktur direktori
openssh-server              # akses admin (dari Modul 1)
```
Sumber repo resmi Debian (trixie main/updates/security). Tidak memakai cdrom.

## 2. Standar direktori data
- Semua data layanan di bawah `/srv/data` (disk terpisah, persisten via fstab UUID).
  - `/srv/data/apps`    — data/berkas aplikasi (grup `ops`, setgid)
  - `/srv/data/backup`  — area backup config & data
  - `/srv/data/logs`    — log aplikasi khusus (bila perlu di luar /var/log)

## 3. Standar permission
- Jangan pernah `chmod 777`.
- Root memiliki `/srv/data` (755).
- Folder kolaborasi service operators pakai grup `ops` + setgid (`2775`).
- User admin (`fishir`) anggota grup `ops`.

## 4. Standar evidence (selalu ada untuk tiap perubahan)
Setiap perubahan harus disertai bukti, minimal:
- output command sebelum/sesudah (mis. `lsblk`, `df -hT`, `ls -ld`, `blkid`).
- entri di `docs/change_log.md` (apa, alasan, rollback).
- file evidence di `evidence/` dengan nama jelas per host.

## 5. Prinsip
System = komponen + kebijakan + konteks. Setiap baseline harus
repeatable (bisa dibangun ulang dari nol) dan verifiable (ada bukti, bukan klaim).
