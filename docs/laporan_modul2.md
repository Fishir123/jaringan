# Laporan Modul 2 — System Components: OS Baseline, Filesystem, Package Management, Logging

Workshop Administrasi Jaringan · PENS — Teknik Informatika dan Komputer

- Kelompok: X = 2 · Fokus host: **srv01** (server inti)
- OS: Debian 13.4 (trixie) · Tanggal: 2026-06-11
- Akses: SSH key-only dari adm01 (Modul 1)

## 1. Ringkasan

Pada srv01 dilakukan baseline audit OS, penambahan disk kedua (8 GB) yang
dipartisi/diformat ext4 dan dimount persisten ke `/srv/data` via UUID,
penerapan kebijakan paket + baseline paket server, serta logging operasional
(journalctl + log aplikasi demo yang ter-rotate via logrotate). Seluruh artefak
diperbarui di repo `lab-admin/`.

## 2. OS Baseline Audit (5.1)

| Item | Hasil |
|------|-------|
| Debian version | 13.4 (trixie) |
| Kernel | 6.12.73+deb13-amd64 |
| CPU / RAM | 2 vCPU / 1.9 GiB |
| Disk awal | sda 20G (sda1 / , sda5 swap) |
| Service running | cron, dbus, ssh, journald, logind, timesyncd, udevd, dll |

Evidence: `evidence/os_audit_srv01.txt`.

## 3. Storage Tambahan (5.2)

Disk kedua `/dev/sdb` (8 GB) ditambahkan di VirtualBox (SATA port 1), lalu:

```
sdb 8G → sdb1 (ext4) → mount /srv/data
UUID=bf696e46-2255-4dca-ab49-9c7d617a93b3 /srv/data ext4 defaults,noatime 0 2
```

- `umount` + `mount -a` diuji → **sukses** (fstab valid, tidak akan gagal boot).
- Struktur: `/srv/data/{apps,backup,logs}`.
- Permission: `/srv/data` 755 root:root; `/srv/data/apps` **2775 root:ops** (setgid),
  user `fishir` ditambahkan ke grup `ops`. Tidak ada 777.

Evidence: `evidence/storage_srv01.txt`, `configs/fstab_notes.md`.

## 4. Package Management (5.3)

- Sumber repo: resmi Debian trixie (main/updates/security), cdrom dinonaktifkan.
- Baseline paket: `vim git curl wget dnsutils net-tools rsyslog logrotate htop tree`.
- Policy: update mingguan/bulanan, hanya admin, upgrade besar wajib catatan + backup config.

Evidence: `evidence/apt_policy_srv01.txt` · Policy: `docs/package_policy_v1.md`.

## 5. Logging Operasional (5.4)

- journald: cek error (`journalctl -p err -b`) dan log service (`journalctl -u ssh -b`).
- Log aplikasi demo: `/usr/local/bin/log-demo.sh` → `/var/log/demo-app.log`.
- Rotasi: `/etc/logrotate.d/demo-app` (daily, rotate 7, compress, delaycompress, copytruncate).
- Uji paksa `logrotate -f` → terbukti: `demo-app.log` (0 byte) + `demo-app.log.1` (186 byte).

Evidence: `evidence/logging_tests_srv01.txt` · Policy: `docs/logging_policy_v1.md`.

## 6. Definition of Done (Checklist)

| Item | Status |
|------|--------|
| Disk kedua terdeteksi, terpartisi, ext4, mount /srv/data | OK |
| /etc/fstab pakai UUID dan mount -a sukses | OK |
| Struktur /srv/data/{apps,backup,logs} + permission sesuai | OK |
| Baseline paket terpasang & terdokumentasi | OK |
| journalctl dipakai untuk cek error & log service | OK |
| demo-app.log ter-rotate dengan logrotate | OK |
| Repo terupdate: docs + configs + scripts + evidence | OK |

## 7. Bukti Screenshot

![Bukti Modul 2 srv01](/home/faiqm/Documents/jaringan/modul1/bukti_modul2_srv01.png)

## 8. Penyimpangan dari Modul

- OS Debian 13 (trixie), bukan Debian 12 — mengikuti ISO yang tersedia.
- User admin `fishir` menggantikan `student` pada contoh modul.
