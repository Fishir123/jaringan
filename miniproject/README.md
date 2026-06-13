# Mini Project — Web Server + Database Server Terpisah

Workshop Administrasi Jaringan · PENS · Kelompok X=2

Aplikasi web (PHP) di satu VM yang terhubung ke database MariaDB di VM lain.
Database TIDAK berada di localhost web server.

## Arsitektur

```
        Klien / Host
            │ HTTP :80
            ▼
   VM1 WEB SERVER (cli01) 10.20.2.10
   ┌─────────────────────────────┐
   │ NGINX + PHP-FPM (php8.4)     │
   │ /srv/data/apps/webapp        │
   │ Webmin :10000                │
   └──────────────┬──────────────┘
                  │ mysqli TCP/IP :3306
                  ▼
   VM2 DATABASE SERVER (adm01) 10.20.2.11
   ┌─────────────────────────────┐
   │ MariaDB 11.8 (bind 10.20.2.11)│
   │ DB: labapp / tabel visitors  │
   │ user: webapp@10.20.2.10      │
   │ Webmin :10000                │
   └─────────────────────────────┘
```

Subnet: LAN-B 10.20.2.0/24 (host-only vboxnet1). Gateway/DNS = srv01 (10.20.2.1).

## Tools (wajib) — status
| Tool | VM | Status |
|------|-----|--------|
| NGINX | VM1 (cli01) | active |
| PHP-FPM (php8.4) | VM1 (cli01) | active |
| Webmin | VM1 (cli01) | active :10000 |
| MariaDB | VM2 (adm01) | active :3306 |
| Webmin | VM2 (adm01) | active :10000 |

## Kunci: DB BUKAN di localhost

MariaDB di VM2 di-bind ke `10.20.2.11` (bukan 127.0.0.1):
```
bind-address = 10.20.2.11
```
User database hanya boleh dari IP web server:
```sql
CREATE USER 'webapp'@'10.20.2.10' IDENTIFIED BY 'WebApp#1206';
GRANT SELECT,INSERT,UPDATE,DELETE ON labapp.* TO 'webapp'@'10.20.2.10';
```
Koneksi PHP (sesuai contoh soal `new mysqli(host,user,pass,db)`):
```php
$conn = new mysqli("10.20.2.11", "webapp", "WebApp#1206", "labapp");
```
Bukti: `host_info` yang dilaporkan mysqli = **"10.20.2.11 via TCP/IP"**
(koneksi jaringan ke VM lain, bukan socket lokal).

## Cara akses
- Web app (browser host): `http://10.20.2.10/` atau `http://webapp.lab2.local`
  (DNS srv01 / entri /etc/hosts).
- Webmin VM1: `https://10.20.2.10:10000`
- Webmin VM2: `https://10.20.2.11:10000`
  (login user `fishir` / password sistem; cert self-signed → terima peringatan).

## Keamanan yang diterapkan
- MariaDB bind ke IP LAN-B saja (tidak ke semua / tidak ekspos publik).
- User DB dibatasi per-host (`@10.20.2.10`) dengan privilege minimum (tanpa GRANT/DDL).
- PHP pakai prepared statement (anti SQL injection) + `htmlspecialchars` (anti XSS).
- Header nginx: `X-Content-Type-Options nosniff`, `X-Frame-Options DENY`.
- Catatan: kredensial DB di `dbconfig.php` (untuk lab). Di produksi gunakan
  secret manager / environment variable, dan TLS untuk koneksi MariaDB.

## Pengujian (terbukti)
1. `mariadb -h 10.20.2.11 -u webapp -p... -e "SELECT 1"` dari VM1 → sukses.
2. `curl http://10.20.2.10/` → halaman menampilkan data dari DB remote.
3. POST form → INSERT row baru (id=3) tersimpan di DB VM2.
4. Webmin kedua VM merespons HTTP 200 di :10000.

Evidence: `evidence/web_to_db_remote.txt`, `webapp_output.txt`, `db_listen.txt`,
screenshot di `Documents/jaringan/miniproject/`.

## Penyimpangan dari ketentuan
- OS Debian 13 (trixie), bukan Debian 12 (mengikuti ISO tersedia). Semua tool
  (NGINX, MariaDB, Webmin, PHP-FPM) tetap terpasang & berfungsi.
- IP sesuai X=2: web 10.20.2.10, DB 10.20.2.11.
