# Laporan Modul 6 — Web Server, Virtual Host, Reverse Proxy & TLS Internal

Workshop Administrasi Jaringan · PENS — Teknik Informatika dan Komputer

- Kelompok: X = 2 · srv01 = Web server + Reverse proxy
- OS: Debian 13.4 (trixie) · Tanggal: 2026-06-12
- Domain: app.lab2.local, portal.lab2.local (DNS Modul 5)

## 1. Ringkasan

srv01 dipasang NGINX dengan dua virtual host (portal statis & app reverse
proxy), backend python sebagai systemd service, dan TLS internal memakai
self-signed CA. Semua diuji dari cli01 via DNS.

## 2. Baseline & Virtual Host (Bagian A & 4)

- NGINX 1.26 aktif. Dua vhost di `sites-enabled`:
  - `portal.lab2.local` → static `/srv/data/apps/portal` (ada ETag).
  - `app.lab2.local` → reverse proxy.
- Default site dinonaktifkan. `nginx -t` sukses.
- Uji dari cli01: `curl http://portal.lab2.local` → "Portal Server";
  `curl http://app.lab2.local` → "Backend App Running".

## 3. Reverse Proxy (5)

- Backend `python3 -m http.server 9000` (bind 127.0.0.1) dijalankan sebagai
  **systemd service demo-backend** (persisten).
- `app.lab2.local` memakai `proxy_pass http://127.0.0.1:9000` dengan header
  `Host` & `X-Real-IP`.
- Bukti: response app "Backend App Running" tanpa ETag (di-proxy).

Detail: `docs/reverse_proxy_design.md`. Evidence: `evidence/curl_http.txt`.

## 4. TLS Internal (6)

- Self-signed **Lab2 Internal CA** menandatangani cert `app.lab2.local` (dengan
  SAN). Dipasang di nginx `listen 443 ssl`.
- CA dipasang di trust store cli01 → `curl https://app.lab2.local` (tanpa -k)
  sukses. `openssl s_client`: TLSv1.3, **Verify return code: 0 (ok)**.

Detail: `docs/tls_internal_policy.md`. Evidence: `evidence/curl_https.txt`.

## 5. Logging, Hardening & Troubleshooting (7 & 8)

- Log per-vhost: `app_access.log`, `portal_access.log` (+ error logs) — terisi.
- `ss -tlnp`: nginx listen 80 & 443, backend 127.0.0.1:9000.
- Hardening: header `X-Content-Type-Options nosniff` & `X-Frame-Options DENY`;
  default site dimatikan; backend tidak diekspos langsung.

Evidence: `evidence/nginx_test.txt`, `evidence/nginx_logs.txt`.

## 6. Analisis (jawaban)

Jawaban pertanyaan 1–4 tersebar di `docs/reverse_proxy_design.md` (web server vs
reverse proxy; kenapa tidak ekspos port langsung) dan `docs/tls_internal_policy.md`
(kenapa TLS wajib internal; risiko private key bocor).

## 7. Definition of Done (Checklist)

| Item | Status |
|------|--------|
| 2 virtual host berjalan | OK (app, portal) |
| Reverse proxy aktif | OK ("Backend App Running") |
| HTTPS internal aktif | OK (TLSv1.3, verify 0) |
| Log terbaca | OK (per-vhost) |
| Repo lengkap | OK |

## 8. Bukti Screenshot

### [1] Virtual host via DNS dari cli01 (app reverse proxy + portal statis)
![vhost](/home/faiqm/Documents/jaringan/modul6/bukti_1_vhost.png)

### [2] HTTPS/TLS internal dari cli01 (verified by internal CA)
![tls](/home/faiqm/Documents/jaringan/modul6/bukti_2_tls.png)

### [3] nginx srv01: config test, ports, vhost, logging
![nginx srv01](/home/faiqm/Documents/jaringan/modul6/bukti_3_nginx_srv01.png)

## 9. Penyimpangan dari Modul

- OS Debian 13 (trixie), bukan Debian 12.
- Backend dijalankan sebagai systemd service (bukan `python3 -m http.server`
  manual) agar persisten & reproducible.
- Cert TLS memakai SAN (wajib untuk verifikasi modern; modul tidak menyebut).
- User admin `fishir` menggantikan `student`.
