# Routing Design v1

Kelompok X=2. srv01 difungsikan sebagai router internal antar dua subnet.

## Diagram subnet

```
        Internet
           |
         [NAT]                       srv01 = ROUTER
           | enp0s3 (10.0.2.15)
   +-------------------+
   |      srv01        |
   | enp0s8     enp0s9 |
   | 10.10.2.11 10.20.2.1
   +---|-----------|---+
       |           |
   LAN-A         LAN-B
 10.10.2.0/24   10.20.2.0/24
 (vboxnet0)     (vboxnet1)
       |           |
   +-------+   +-------+
   | adm01 |   | cli01 |
   |.10    |   |.2  gw=10.20.2.1
   +-------+   +-------+
```

## IP Plan
| Host  | Interface | IP            | Subnet        | Gateway     |
|-------|-----------|---------------|---------------|-------------|
| srv01 | enp0s8    | 10.10.2.11/24 | LAN-A         | -           |
| srv01 | enp0s9    | 10.20.2.1/24  | LAN-B         | - (router)  |
| adm01 | enp0s8    | 10.10.2.10/24 | LAN-A         | route ke B  |
| cli01 | enp0s8    | 10.20.2.2/24  | LAN-B         | 10.20.2.1   |

## Routing logic
- adm01 dan cli01 berada di subnet berbeda (LAN-A vs LAN-B) sehingga tidak bisa
  berkomunikasi langsung di layer-2.
- srv01 punya kaki di kedua subnet dan dengan `ip_forward=1` meneruskan paket
  antar interface (enp0s8 <-> enp0s9).
- cli01 memakai srv01 (10.20.2.1) sebagai default gateway → paket ke LAN-A
  dikirim ke srv01 untuk diteruskan.
- adm01 tidak menjadikan srv01 default gateway (default-nya tetap NAT untuk
  internet), maka ditambahkan **static route**: `10.20.2.0/24 via 10.10.2.11`.

## Kenapa butuh gateway
Host hanya bisa mengirim langsung ke alamat dalam subnetnya sendiri. Untuk
tujuan di luar subnet, paket dikirim ke gateway (router) yang tahu cara
meneruskannya ke subnet lain. Tanpa gateway/route yang benar, paket lintas
subnet tidak punya jalan dan koneksi gagal.

## Bukti (TTL)
adm01 → cli01 menghasilkan TTL=63 (dari 64, berkurang 1) → membuktikan paket
melewati 1 hop router (srv01). Capture tcpdump di srv01 menunjukkan paket
masuk di enp0s8 dan keluar di enp0s9.

Evidence: `evidence/route_table_srv01.txt`, `evidence/ip_forward_check.txt`.
