# DNS Design v1 (Modul 5)

Kelompok X=2. DNS authoritative internal di srv01 (BIND9) untuk domain
`lab2.local` dan reverse zone subnet LAN-B.

## Domain & Zone
- Forward zone: `lab2.local` → file `/etc/bind/db.lab2.local`
- Reverse zone: `2.20.10.in-addr.arpa` → file `/etc/bind/db.10.20.2`
  (untuk subnet 10.20.2.0/24)

## Records (forward)
| Nama | Tipe | Nilai |
|------|------|-------|
| @ | NS | srv01.lab2.local. |
| srv01 | A | 10.20.2.1 |
| cli01 | A | 10.20.2.2 |
| adm01 | A | 10.10.2.10 |

## Records (reverse)
| PTR | → |
|-----|---|
| 1 (10.20.2.1) | srv01.lab2.local. |
| 2 (10.20.2.2) | cli01.lab2.local. |

## SOA record
```
@ IN SOA srv01.lab2.local. root.lab2.local. (
    2025060501 ; Serial (WAJIB di-increment tiap ubah zona)
    604800     ; Refresh - kapan slave cek master
    86400      ; Retry - jeda retry jika refresh gagal
    2419200    ; Expire - kapan data dianggap basi
    604800 )   ; Negative Cache TTL
```
SOA = Start Of Authority: menandai server otoritatif untuk zona, memuat serial
& timer replikasi. Serial harus naik tiap perubahan agar slave/cache tahu ada
update.

## Validasi & uji
```
named-checkconf
named-checkzone lab2.local /etc/bind/db.lab2.local
dig @127.0.0.1 srv01.lab2.local      # forward
dig @127.0.0.1 -x 10.20.2.2          # reverse
```

## Koreksi terhadap modul
Modul menulis reverse zone `20.10.in-addr.arpa` dengan PTR `1`/`2`. Untuk /24 di
`10.20.2.0` yang benar adalah `2.20.10.in-addr.arpa` (PTR `1`/`2` →
10.20.2.1/.2). Versi modul akan memetakan ke 10.20.0.x sehingga reverse lookup
host kita gagal. Dikoreksi di konfigurasi.

Evidence: `evidence/dig_forward.txt`, `evidence/dig_reverse.txt`.
