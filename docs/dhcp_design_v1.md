# DHCP Design v1 (Modul 5)

Kelompok X=2. DHCP server di srv01 (isc-dhcp-server) melayani LAN-B (enp0s9).

## Interface
`/etc/default/isc-dhcp-server`:
```
INTERFACESv4="enp0s9"
```
DHCP hanya listen di enp0s9 (10.20.2.1) — jaringan klien. TIDAK di enp0s8/enp0s3
agar tidak mengganggu LAN-A maupun NAT.

## Scope / subnet
`/etc/dhcp/dhcpd.conf`:
```
subnet 10.20.2.0 netmask 255.255.255.0 {
    range 10.20.2.50 10.20.2.100;       # pool dinamis
    option routers 10.20.2.1;            # gateway = srv01
    option domain-name "lab2.local";
    option domain-name-servers 10.20.2.1; # DNS = srv01
}
```
- Pool dinamis: .50–.100.
- Gateway & DNS diarahkan ke srv01 sehingga klien otomatis memakai router dan
  DNS internal.

## Reservation (fixed-address)
```
host cli01 {
    hardware ethernet 08:00:27:65:ff:50;
    fixed-address 10.20.2.10;
}
```
cli01 (berdasarkan MAC) selalu mendapat 10.20.2.10, di luar pool dinamis. Berguna
untuk host yang butuh IP stabil (server kecil, printer) tanpa konfigurasi statik
manual di klien.

## Uji
```
# di klien (cli01):
ip -4 a            # IP dari DHCP
ip r               # default via 10.20.2.1
cat /etc/resolv.conf  # nameserver 10.20.2.1, domain lab2.local
# renew: ifdown/ifup enp0s8 (klien pakai dhcpcd)
# di server:
systemctl status isc-dhcp-server
grep -A8 "^lease" /var/lib/dhcp/dhcpd.leases
```

## Catatan implementasi
- Host-only vboxnet1 DHCP-nya dimatikan agar tidak bentrok dengan ISC DHCP srv01.
- Klien Debian 13 memakai `dhcpcd` (bukan `dhclient`); renew via ifdown/ifup.

Evidence: `evidence/dhcp_lease.txt`.
