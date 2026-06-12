# Infrastructure Architecture v1 (Modul 5)

Kelompok X=2. Ringkasan layanan inti infrastruktur internal lab.

## Peran host
| Host  | Peran | Layanan |
|-------|-------|---------|
| srv01 | Core server | Router (Modul 4) + DNS (BIND9) + DHCP (ISC) |
| adm01 | Admin workstation | SSH client, manajemen |
| cli01 | Client | DHCP client, konsumen layanan |

## Topologi layanan
```
                 srv01 (10.20.2.1 / 10.10.2.11)
   +-------------------------------------------------+
   |  BIND9 (DNS)      ISC-DHCP        IP forwarding  |
   |  zona lab2.local  pool .50-.100   LAN-A <-> LAN-B|
   |  reverse 2.20.10  resv cli01 .10                 |
   +----------------------|--------------------------+
                          | enp0s9 (LAN-B)
                    10.20.2.0/24
                          |
                      cli01 (DHCP -> .10)
                      gateway+DNS = 10.20.2.1
```

## Alur klien saat boot (cli01)
1. Kirim DHCP DISCOVER di LAN-B.
2. srv01 (ISC DHCP) menjawab OFFER → cli01 dapat IP (reservation .10),
   gateway 10.20.2.1, DNS 10.20.2.1, domain lab2.local.
3. Resolusi nama (`srv01.lab2.local`) ditangani BIND9 di srv01.
4. Trafik keluar subnet diteruskan srv01 (IP forwarding + route).

## Pertanyaan analitis

**a. Kenapa DNS lebih penting dari sekadar /etc/hosts?**
`/etc/hosts` bersifat lokal per-mesin dan harus disalin/diupdate manual di tiap
host — tidak skalabel. DNS terpusat: satu sumber kebenaran, update sekali di
server langsung dipakai semua klien, mendukung banyak record (A, PTR, MX, dst),
caching, dan delegasi.

**b. Kenapa reverse zone penting?**
Reverse (IP→nama) dipakai untuk logging yang terbaca, verifikasi (mis. mail
server, rDNS check), dan troubleshooting. Banyak layanan mencatat/memvalidasi
berdasar nama hasil reverse lookup.

**c. Apa risiko jika DHCP dan DNS tidak sinkron?**
Klien bisa dapat IP tapi nama tidak resolve (atau resolve ke IP lama), sehingga
koneksi by-hostname gagal, sertifikat/logging salah, dan troubleshooting jadi
membingungkan. IP yang berpindah tanpa update DNS = data basi.

**d. Apa beda recursive vs authoritative DNS?**
- *Authoritative*: server yang memegang data zona dan menjawab dengan otoritas
  (BIND9 kita untuk lab2.local).
- *Recursive*: server yang mencarikan jawaban untuk klien dengan menelusuri
  hierarki DNS (root→TLD→authoritative) lalu meng-cache hasilnya.

**e. Kenapa domain .local tidak cocok untuk production global?**
`.local` adalah pseudo-TLD yang bertabrakan dengan mDNS (RFC 6762) dan tidak
bisa didelegasikan secara global di internet. Untuk production gunakan domain
terdaftar (mis. example.com) atau subdomain internal di bawahnya.

## Definition of Done (checklist)
| Item | Status |
|------|--------|
| cli01 dapat IP otomatis | OK (DHCP) |
| Gateway benar (10.20.2.1) | OK |
| DNS server benar (10.20.2.1) | OK |
| Forward & reverse lookup | OK |
| DHCP reservation terbukti | OK (cli01 .10) |
| Repo & evidence lengkap | OK |
