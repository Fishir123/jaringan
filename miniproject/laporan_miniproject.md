# Laporan Mini Project — Web Server + Database Server Terpisah

Workshop Administrasi Jaringan · PENS — Teknik Informatika dan Komputer
Kelompok X = 2 · Tanggal: 2026-06-13 · OS: Debian 13.4 (trixie)

## 1. Ketentuan & Pemenuhan

| Ketentuan | Pemenuhan |
|-----------|-----------|
| VM1 Web Server: NGINX + PHP-FPM + Webmin, IP 10.20.X.10 | cli01 10.20.2.10 ✔ |
| VM2 DB Server: MariaDB + Webmin, IP 10.20.X.11 | adm01 10.20.2.11 ✔ |
| ❌ database TIDAK di localhost | MariaDB bind 10.20.2.11 ✔ |
| ✔ web konek ke MariaDB di VM lain | mysqli ke 10.20.2.11 ✔ |

## 2. Arsitektur

```
Host/Klien ─HTTP:80─> VM1 cli01 (NGINX+PHP-FPM) ─mysqli TCP:3306─> VM2 adm01 (MariaDB)
   10.20.2.10                                          10.20.2.11
   Webmin :10000                                       Webmin :10000
```
LAN-B 10.20.2.0/24, gateway/DNS srv01 (10.20.2.1).

## 3. Database Server (VM2 — adm01)

- MariaDB 11.8 aktif, `bind-address = 10.20.2.11` → listen `10.20.2.11:3306`
  (BUKAN 127.0.0.1).
- DB `labapp`, tabel `visitors`.
- User remote dibatasi per-host: `webapp'@'10.20.2.10` dengan privilege minimum.
- Webmin aktif di :10000.

## 4. Web Server (VM1 — cli01)

- NGINX + PHP-FPM (php8.4) aktif; vhost `webapp` root `/srv/data/apps/webapp`.
- Aplikasi PHP `index.php` koneksi ke DB remote (sesuai contoh soal):
  ```php
  $conn = new mysqli("10.20.2.11", "webapp", "WebApp#1206", "labapp");
  ```
- Webmin aktif di :10000.

## 5. Bukti Koneksi DB Remote (bukan localhost)

`mysqli->host_info` melaporkan **"10.20.2.11 via TCP/IP"** — koneksi jaringan ke
VM lain. Test langsung `mariadb -h 10.20.2.11 ...` dari VM1 → "WEB->DB REMOTE OK".
POST form web → INSERT row id=3 tersimpan di DB VM2.

Evidence: `miniproject/evidence/web_to_db_remote.txt`, `webapp_output.txt`,
`db_listen.txt`.

## 6. Cara Akses

- Web app: `http://10.20.2.10/` atau `http://webapp.lab2.local`.
- Webmin VM1: `https://10.20.2.10:10000` · Webmin VM2: `https://10.20.2.11:10000`
  (login user sistem `fishir`; cert self-signed, terima peringatan browser).

## 7. Keamanan

- MariaDB bind ke IP LAN-B saja; user DB per-host + privilege minimum.
- PHP prepared statement (anti SQLi) + htmlspecialchars (anti XSS).
- Header nginx nosniff & X-Frame-Options DENY.
- Catatan produksi: simpan kredensial via secret manager/env, aktifkan TLS untuk
  koneksi MariaDB.

## 8. Cron Job (penjadwalan otomatis)

Tiga cron job dipasang lewat `/etc/cron.d/` (format dengan field user).

| # | VM | Jadwal | Script | Fungsi |
|---|----|--------|--------|--------|
| 1 | adm01 (DB) | `0 2 * * *` (02:00 harian) | `/usr/local/sbin/db_backup.sh` | Backup `labapp` via mysqldump -> `/srv/backup/mariadb/*.sql.gz` |
| 2 | cli01 (Web) | `*/5 * * * *` (tiap 5 menit) | `/usr/local/sbin/web_db_healthcheck.sh` | Cek koneksi web -> DB remote, log UP/DOWN |
| 3 | adm01 (DB) | `30 2 * * *` (02:30 harian) | `/usr/local/sbin/db_backup_cleanup.sh` | Retensi: hapus backup > 7 hari |

Bukti berjalan otomatis: log health check terisi pada `00:00:01` oleh cron
(`*/5`), bukan eksekusi manual. Backup menghasilkan file `.sql.gz` valid
(berisi `CREATE TABLE visitors` + data). Log di `/var/log/db_backup.log` dan
`/var/log/web_db_health.log`.

Evidence: `evidence/cron_db_backup.txt`, `evidence/cron_web_healthcheck.txt`.
Script & cron file di `scripts/` dan `configs/cron_*.cron`.

## 9. Bukti Screenshot

### [1] Aplikasi web (browser) — menampilkan data dari DB remote
![web app](/home/faiqm/Documents/jaringan/miniproject/bukti_1_webapp.png)

### [2] VM2 Database Server (adm01) — MariaDB :3306 + Webmin + data
![db server](/home/faiqm/Documents/jaringan/miniproject/bukti_2_db_server.png)

### [3] VM1 Web Server (cli01) — NGINX/PHP-FPM/Webmin + test DB remote
![web server](/home/faiqm/Documents/jaringan/miniproject/bukti_3_web_server.png)

### [4] Cron job DB server (adm01) — backup + retensi + log
![cron db](/home/faiqm/Documents/jaringan/miniproject/bukti_4_cron_db.png)

### [5] Cron job Web server (cli01) — health check + log otomatis
![cron web](/home/faiqm/Documents/jaringan/miniproject/bukti_5_cron_web.png)

Catatan: Webmin (kedua VM) terbukti aktif lewat status service & listen :10000
pada screenshot konsol, serta halaman "Login to Webmin" (HTTP 200) saat diakses.
Screenshot browser Webmin tidak disertakan karena cert self-signed memblok render
headless; akses manual lewat browser tetap berfungsi.

## 9. Penyimpangan

- OS Debian 13 (trixie), bukan Debian 12 — seluruh tool wajib (NGINX, PHP-FPM,
  MariaDB, Webmin) tetap terpasang & berfungsi.
- User admin `fishir` (bukan `student`).
