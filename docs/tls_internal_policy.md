# TLS Internal Policy (Modul 6)

Kelompok X=2. TLS internal memakai self-signed Certificate Authority (CA).

## Hierarki
```
Lab2 Internal CA (labCA.crt / labCA.key)   <- root of trust
        │ menandatangani
        ▼
app.lab2.local (app.crt / app.key)         <- server certificate
```

## Pembuatan (di srv01, /root/ca)
```bash
# 1. Internal CA
openssl genrsa -out labCA.key 2048
openssl req -x509 -new -nodes -key labCA.key -sha256 -days 365 \
  -subj "/C=ID/O=Lab2/CN=Lab2 Internal CA" -out labCA.crt

# 2. Cert app.lab2.local (dengan SAN)
openssl genrsa -out app.key 2048
openssl req -new -key app.key -subj "/.../CN=app.lab2.local" -out app.csr
openssl x509 -req -in app.csr -CA labCA.crt -CAkey labCA.key -CAcreateserial \
  -out app.crt -days 365 -sha256 -extfile <(echo "subjectAltName=DNS:app.lab2.local")
```
SAN (Subject Alternative Name) wajib — browser/curl modern mengabaikan CN dan
memeriksa SAN.

## Pemasangan di nginx
```nginx
listen 443 ssl;
ssl_certificate     /etc/nginx/ssl/app.crt;
ssl_certificate_key /etc/nginx/ssl/app.key;   # chmod 600
```

## Trust di klien
CA cert (`labCA.crt`) dipasang di cli01:
```
/usr/local/share/ca-certificates/lab2CA.crt
sudo update-ca-certificates
```
Setelah itu `curl https://app.lab2.local` (tanpa `-k`) sukses, dan
`openssl s_client` melaporkan **Verify return code: 0 (ok)**, TLSv1.3.

## Pertanyaan analitis

**2. Kenapa TLS wajib meskipun internal?**
Mencegah penyadapan & MITM di jaringan internal (insider threat, perangkat yang
disusupi), melindungi kredensial/cookie, dan memastikan integritas data. Jaringan
internal bukan berarti tepercaya (zero-trust).

**3. Apa risiko jika private key bocor?**
Penyerang bisa menyamar sebagai server (impersonasi), mendekripsi/MITM trafik,
dan menandatangani sertifikat palsu (jika yang bocor adalah key CA → seluruh
domain internal terkompromi). Mitigasi: simpan key dengan permission ketat
(600, root), rotasi, dan revoke bila bocor.

## Kebijakan
- Private key: permission 600, hanya root.
- Key CA tidak pernah dikopi ke klien (hanya cert publik labCA.crt).
- Masa berlaku cert 365 hari; rotasi sebelum kedaluwarsa.

Evidence: `evidence/curl_https.txt`.
