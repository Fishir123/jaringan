# Policy Blueprint v0

Kelompok X=2 · Skenario: WSN/IoT Lab Kampus (Opsi A)

## 1. Tujuan sistem
Menyediakan mini-infrastruktur lab untuk simulasi gateway IoT/WSN kampus.
Lab terdiri dari admin workstation (adm01), server inti (srv01), dan client uji
(cli01) di LAN internal 10.10.2.0/24, dikelola dengan prinsip policy-first,
repeatable, dan dapat diaudit.

## 2. Aset & risiko
- Server inti srv01 (calon DNS/layanan internal) — risiko: akses tidak sah, kehilangan layanan nama.
- Kredensial admin & SSH key — risiko: kebocoran private key, password lemah.
- Konfigurasi jaringan LAN — risiko: salah interface (NAT vs LAN), IP bentrok.
- Integritas dokumentasi/repo — risiko: drift antara kondisi nyata dan dokumen.
- Saluran apt via NAT — risiko: paket dari sumber tidak tepercaya.

## 3. Kebijakan akses
- Admin: user `fishir` (anggota grup sudo). Hanya adm01 yang menyimpan private key.
- Aturan SSH: key-only (PasswordAuthentication no), root login dilarang
  (PermitRootLogin no), PubkeyAuthentication yes.
- Password auth hanya dimatikan SETELAH key login terverifikasi (hindari lockout).

## 4. Standar konfigurasi
- Naming: hostname wajib adm01/srv01/cli01 = nama VM di hypervisor. Domain draft lab2.local.
- IP plan: LAN 10.10.2.0/24 → adm01 .10, srv01 .11, cli01 .12. Gateway LAN kosong (routing modul lanjut).
- NIC: NIC1 NAT (apt/internet), NIC2 Host-only (LAN internal).
- Dokumentasi wajib: inventory, policy blueprint, topology, change_log, evidence di repo git.

## 5. Definisi sukses Modul 1 (checklist)
- [x] 3 VM jalan, 2 NIC per VM benar
- [x] IP statik LAN benar, saling ping (0% loss)
- [x] SSH key-based adm01 → srv01 & cli01 tanpa password
- [x] root login off, password auth off (tanpa mengunci diri)
- [x] inventory + policy blueprint v0 tersedia
- [x] evidence (ping/ssh/ip a) tersimpan
- [x] change_log minimal 3 perubahan + alasan
