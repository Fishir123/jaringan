# Storage Policy v1

## Tujuan /srv/data
Menyediakan area penyimpanan data layanan yang terpisah dari root filesystem
(`/`), pada disk kedua (`/dev/sdb`). Tujuannya: isolasi data dari OS, kemudahan
backup, dan mencegah `/` penuh karena data aplikasi.

## Aturan permission
- Dilarang `chmod 777` pada direktori manapun di `/srv/data`.
- Kepemilikan dasar `root:root`, mode `755` untuk `/srv/data`.
- Direktori kolaborasi (`/srv/data/apps`) memakai grup `ops` dengan setgid `2775`
  agar file baru otomatis mewarisi grup `ops`.
- Hanya anggota grup `ops` (service operators) yang boleh menulis ke `apps`.

## Aturan fstab
- Mount WAJIB memakai `UUID`, bukan nama device (`/dev/sdb1`) yang bisa berubah.
- Opsi minimal: `defaults,noatime`, dump `0`, pass `2`.
- Setiap perubahan fstab harus diuji dengan `umount` + `mount -a` sebelum
  dianggap selesai (hindari sistem gagal boot karena fstab salah).

## Aturan backup
- Folder `/srv/data/backup` disiapkan sebagai target backup config & data penting.
- Backup config penting wajib dilakukan SEBELUM upgrade besar (lihat package policy).
- Retensi & jadwal backup difinalisasi di modul layanan berikutnya.

## Disk saat ini (srv01)
- `/dev/sdb` 8 GB → `/dev/sdb1` ext4 → mount `/srv/data`.
- UUID: `bf696e46-2255-4dca-ab49-9c7d617a93b3`.
