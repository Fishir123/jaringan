# Laporan Modul 5 — Infrastructure Core Services: DNS + DHCP

Workshop Administrasi Jaringan · PENS — Teknik Informatika dan Komputer

- Kelompok: X = 2 · srv01 = Router + DNS + DHCP
- OS: Debian 13.4 (trixie) · Tanggal: 2026-06-12
- Domain internal: `lab2.local` · LAN-B: 10.20.2.0/24

## 1. Ringkasan

srv01 dilengkapi DNS authoritative (BIND9) untuk `lab2.local` (forward + reverse)
dan DHCP server (ISC) untuk LAN-B dengan reservation. cli01 dijadikan DHCP client
dan terbukti menerima IP, gateway, dan DNS otomatis serta dapat me-resolve
hostname.

## 2. DNS Server (Bagian A)

- BIND9 aktif, zona master:
  - forward `lab2.local` → `/etc/bind/db.lab2.local`
  - reverse `2.20.10.in-addr.arpa` → `/etc/bind/db.10.20.2`
- Records: srv01→10.20.2.1, cli01→10.20.2.2, adm01→10.10.2.10; PTR .1/.2.
- Validasi `named-checkconf` & `named-checkzone` OK; serial SOA = 2025060501.
- Uji: `dig srv01.lab2.local` & `dig -x 10.20.2.2` resolve benar.

Detail & SOA: `docs/dns_design_v1.md`. Evidence: `evidence/dig_forward.txt`, `dig_reverse.txt`.

## 3. DHCP Server (Bagian B)

- isc-dhcp-server listen di `enp0s9` (LAN-B).
- subnet 10.20.2.0/24: pool .50–.100, `option routers 10.20.2.1`,
  `domain-name lab2.local`, `domain-name-servers 10.20.2.1`.
- Service aktif; lease tercatat di `/var/lib/dhcp/dhcpd.leases`.

Detail: `docs/dhcp_design_v1.md`. Evidence: `evidence/dhcp_lease.txt`.

## 4. DHCP Reservation (Advanced)

```
host cli01 {
    hardware ethernet 08:00:27:65:ff:50;
    fixed-address 10.20.2.10;
}
```
Setelah renew, cli01 berpindah dari .50 (pool) ke **10.20.2.10** (reservation) —
terbukti.

## 5. Integrasi DNS + DHCP (dari cli01)

- IP otomatis: 10.20.2.10 (reservation)
- Gateway: 10.20.2.1 · DNS: 10.20.2.1 · domain: lab2.local
- `getent hosts srv01.lab2.local` → 10.20.2.1; `ping srv01.lab2.local` 0% loss.

## 6. Analisis (jawaban)

Jawaban lengkap pertanyaan a–e (DNS vs /etc/hosts, reverse zone, risiko DHCP/DNS
tak sinkron, recursive vs authoritative, kenapa .local tak cocok production) ada
di `docs/infra_architecture_v1.md`.

## 7. Definition of Done (Checklist)

| Item | Status |
|------|--------|
| cli01 dapat IP otomatis | OK |
| Gateway benar (10.20.2.1) | OK |
| DNS server benar (10.20.2.1) | OK |
| Forward & reverse lookup | OK |
| DHCP reservation terbukti | OK (.10) |
| Repo & evidence lengkap | OK |

## 8. Bukti Screenshot

### [1] DNS srv01: forward & reverse lookup
![DNS srv01](/home/faiqm/Documents/jaringan/modul5/bukti_1_srv01_dns.png)

### [2] DHCP server srv01: service, lease & reservation
![DHCP srv01](/home/faiqm/Documents/jaringan/modul5/bukti_2_srv01_dhcp.png)

### [3] cli01 DHCP client (reservation 10.20.2.10 + gw + DNS)
![cli01 DHCP](/home/faiqm/Documents/jaringan/modul5/bukti_3_cli01_dhcp.png)

### [4] Integrasi DNS dari cli01 (resolve + ping by hostname)
![cli01 DNS](/home/faiqm/Documents/jaringan/modul5/bukti_4_cli01_dns.png)

## 9. Penyimpangan dari Modul

- OS Debian 13 (trixie), bukan Debian 12.
- Reverse zone dikoreksi ke `2.20.10.in-addr.arpa` (modul menulis
  `20.10.in-addr.arpa` yang keliru untuk /24 di 10.20.2.0).
- Konfigurasi klien via ifupdown + `dhcpcd` (bukan nmcli/dhclient).
- User admin `fishir` menggantikan `student`.
