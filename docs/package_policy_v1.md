# Package Policy v1

## Sumber repo
Hanya repo resmi Debian (trixie):
```
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates ...
deb http://security.debian.org/debian-security trixie-security ...
```
Repo `cdrom:` dinonaktifkan (tidak dapat di-update online dan tidak konsisten).

## Kapan update dilakukan
- `apt update` + cek keamanan: mingguan.
- `apt upgrade` rutin: bulanan, di luar jam sibuk.
- Patch keamanan kritis: secepatnya setelah verifikasi.

## Siapa yang boleh update
- Hanya admin (anggota sudo, mis. `fishir`).
- Tidak ada update otomatis tanpa pencatatan.

## Aturan upgrade besar
- Dilarang `dist-upgrade`/upgrade besar tanpa:
  1. catatan di `docs/change_log.md` (alasan + daftar paket),
  2. backup config penting ke `/srv/data/backup`,
  3. rencana rollback.

## Baseline paket (server srv01)
`vim git curl wget dnsutils net-tools rsyslog logrotate htop tree openssh-server`

Bukti versi terpasang: `evidence/apt_policy_srv01.txt`.

## Prinsip
Paket = supply chain. Sumber, versi, dan kebijakan update harus terdokumentasi
agar sistem dapat diaudit dan diulang.
