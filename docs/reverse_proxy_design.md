# Reverse Proxy Design (Modul 6)

## Konsep
Reverse proxy (nginx) menerima request dari klien dan meneruskannya ke backend
internal, lalu mengembalikan response backend ke klien. Klien tidak pernah
berkomunikasi langsung dengan backend.

```
cli01 ──HTTP/HTTPS──> nginx (app.lab2.local :80/:443)
                         │ proxy_pass
                         ▼
                  backend 127.0.0.1:9000 (python http.server)
```

## Konfigurasi (app.lab2.local)
```nginx
location / {
    proxy_pass http://127.0.0.1:9000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```
- `proxy_pass`: tujuan backend.
- `Host`: meneruskan nama host asli ke backend.
- `X-Real-IP`: meneruskan IP klien asli (backend tahu siapa pemanggil).

## Bukti reverse proxy bekerja
- `curl http://app.lab2.local` → "Backend App Running" (konten dari :9000, bukan
  file statis app/index.html).
- Response app **tanpa ETag** (di-proxy), berbeda dengan portal (statis, ada ETag).

## Pertanyaan analitis

**1. Apa perbedaan web server dan reverse proxy?**
Web server melayani konten sendiri (file statis / aplikasi). Reverse proxy tidak
menyimpan konten — ia perantara yang meneruskan request ke backend lain dan bisa
menambah TLS termination, load balancing, caching, dan header keamanan. Nginx di
sini berperan dua: web server (portal) sekaligus reverse proxy (app).

**4. Kenapa tidak semua service expose port langsung?**
- Mengurangi attack surface: hanya nginx (80/443) yang publik, backend bind ke
  127.0.0.1 (tidak bisa diakses dari jaringan).
- Sentralisasi TLS, logging, rate-limit, dan header keamanan di satu titik.
- Backend bisa diganti/diskalakan tanpa mengubah endpoint klien.

Evidence: `evidence/curl_http.txt`.
