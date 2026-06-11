# lab-admin — Workshop Administrasi Jaringan (Modul 1)

Repo konfigurasi & dokumentasi lab SysAdmin. Skenario PBL: **Opsi A — WSN/IoT Lab Kampus**.

Nomor kelompok: **X = 2** → LAN `10.10.2.0/24`, domain internal draft `lab2.local`.

## Topologi (3 VM Debian 13)

| Host  | Role               | IP LAN (enp0s8) | NAT (enp0s3) |
|-------|--------------------|-----------------|--------------|
| adm01 | admin workstation  | 10.10.2.10/24   | DHCP 10.0.2.15 |
| srv01 | server inti        | 10.10.2.11/24   | DHCP 10.0.2.15 |
| cli01 | client uji         | 10.10.2.12/24   | DHCP 10.0.2.15 |

Host-only network (VirtualBox `vboxnet0`): gateway host `10.10.2.1/24`, DHCP off.

## Struktur

```
lab-admin/
  docs/
    inventory_v0.md
    policy_blueprint_v0.md
    topology.md
    change_log.md
  configs/
    sshd_config_notes.md
  evidence/
    ping_tests.txt
    ssh_tests.txt
    ip_a_all.txt
  README.md
```

## Definition of Done (Modul 1)

- [x] adm01 bisa SSH ke srv01 tanpa password (key-based)
- [x] adm01 bisa SSH ke cli01 tanpa password (key-based)
- [x] ping LAN antar VM sukses (0% loss)
- [x] inventory + policy blueprint ada
- [x] evidence tersimpan
- [x] root login off, password auth off (key sudah berhasil dulu → tidak terkunci)

## Catatan penyimpangan dari modul

- OS yang dipakai **Debian 13 (trixie)**, bukan Debian 12, mengikuti ISO yang tersedia.
- Network manager **ifupdown** (`/etc/network/interfaces.d/lan0`), bukan NetworkManager/nmcli — adaptasi ke kondisi instalasi aktual. Hasil akhir (IP statik LAN) sama.
