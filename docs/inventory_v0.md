# System Inventory v0

Tanggal: 2026-06-11 · Kelompok X=2 · LAN 10.10.2.0/24

## Daftar VM

### adm01
- Hostname: adm01
- Role: admin workstation
- IP (LAN): 10.10.2.10/24 (enp0s8)
- Interface LAN: enp0s8 (Host-only vboxnet0)
- NIC mapping: enp0s3 = NAT (DHCP), enp0s8 = Host-only LAN (statik)
- Debian version (/etc/debian_version): 13.4
- SSH: key-only? N (workstation — menyimpan private key, password auth masih aktif)
- Notes: pemegang SSH key ed25519 (`adm01@lab2`), titik akses admin ke srv01 & cli01

### srv01
- Hostname: srv01
- Role: server inti
- IP (LAN): 10.10.2.11/24 (enp0s8)
- Interface LAN: enp0s8 (Host-only vboxnet0)
- NIC mapping: enp0s3 = NAT (DHCP), enp0s8 = Host-only LAN (statik)
- Debian version (/etc/debian_version): 13.4
- SSH: key-only? Y (PasswordAuthentication no, PermitRootLogin no)
- Notes: menerima pubkey adm01; kandidat DNS internal (modul berikutnya)

### cli01
- Hostname: cli01
- Role: client uji
- IP (LAN): 10.10.2.12/24 (enp0s8)
- Interface LAN: enp0s8 (Host-only vboxnet0)
- NIC mapping: enp0s3 = NAT (DHCP), enp0s8 = Host-only LAN (statik)
- Debian version (/etc/debian_version): 13.4
- SSH: key-only? Y (PasswordAuthentication no, PermitRootLogin no)
- Notes: menerima pubkey adm01

## User admin awal (tanpa password)
- Username: fishir (sudo via grup sudo)
- Disusun untuk akses admin; root login SSH dimatikan.

## Paket penting yang dipasang
openssh-server, git, vim, curl, wget, net-tools, dnsutils

## Status akses SSH (key-based)
- adm01 → srv01 (10.10.2.11): OK, tanpa password
- adm01 → cli01 (10.10.2.12): OK, tanpa password
- Key: ed25519, comment `adm01@lab2`
