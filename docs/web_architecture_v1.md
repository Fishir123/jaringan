# Web Architecture v1 (Modul 6)

Kelompok X=2. srv01 sebagai web server + reverse proxy + TLS internal.

## Komponen
| Komponen | Detail |
|----------|--------|
| Web server | NGINX 1.26 di srv01 |
| Virtual host 1 | `portal.lab2.local` → static `/srv/data/apps/portal` |
| Virtual host 2 | `app.lab2.local` → reverse proxy ke backend :9000 |
| Backend | python `http.server` :9000 (systemd: demo-backend.service) |
| TLS | self-signed internal CA (Lab2 Internal CA) → cert app.lab2.local |
| DNS | app & portal → A 10.20.2.1 (BIND9 dari Modul 5) |

## Alur request
```
cli01 --(DNS lab2.local)--> 10.20.2.1
  http://portal.lab2.local  -> nginx vhost -> file statis
  http://app.lab2.local     -> nginx vhost -> proxy_pass 127.0.0.1:9000
  https://app.lab2.local    -> nginx TLS   -> proxy_pass 127.0.0.1:9000
```

## Direktori web
```
/srv/data/apps/app/index.html      (App Server)
/srv/data/apps/portal/index.html   (Portal Server)
/srv/data/apps/backend/index.html  (Backend App Running)
```
Owner www-data:www-data.

## Logging (per-vhost)
- `/var/log/nginx/app_access.log` + `app_error.log`
- `/var/log/nginx/portal_access.log` + `portal_error.log`
- Troubleshoot: `nginx -t`, `ss -tlnp | grep nginx`, `tail -f` log.

## Hardening minimum
- `add_header X-Content-Type-Options nosniff;`
- `add_header X-Frame-Options DENY;`
- Default site dinonaktifkan (`rm /etc/nginx/sites-enabled/default`).

Evidence: `evidence/nginx_test.txt`, `evidence/nginx_logs.txt`,
`evidence/curl_http.txt`, `evidence/curl_https.txt`.

## Catatan implementasi
Backend dijalankan sebagai **systemd service** (demo-backend.service), bukan
`python3 -m http.server` manual di terminal seperti di modul, agar persisten &
auto-restart (reproducible). Bind ke 127.0.0.1 saja (tidak diekspos langsung).
