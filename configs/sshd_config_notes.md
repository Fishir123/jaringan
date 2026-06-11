# sshd_config notes

Hardening diterapkan di srv01 dan cli01 lewat drop-in file
`/etc/ssh/sshd_config.d/99-hardening.conf` (bukan mengedit sshd_config utama,
agar mudah di-rollback dan tidak bentrok update paket).

## Isi 99-hardening.conf (srv01 & cli01)

```
# Modul 1 baseline hardening
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

## Urutan kerja (penting — hindari lockout)
1. Pasang pubkey adm01 ke ~/.ssh/authorized_keys target.
2. Verifikasi key login `ssh fishir@<ip>` BERHASIL tanpa password.
3. Baru terapkan hardening dan `sshd -t` (validasi syntax).
4. `systemctl restart ssh`.
5. Uji ulang key login dari adm01 → harus tetap masuk.

## Verifikasi (hasil aktual)
- Password auth ke srv01/cli01: ditolak → `Permission denied (publickey)`.
- Key login dari adm01 ke srv01 & cli01: OK.

## adm01
Sebagai admin workstation, adm01 menyimpan private key (`~/.ssh/id_ed25519`)
dan tidak dihardening seketat target (masih boleh password auth lokal).
Tidak ada pubkey pihak lain yang dipasang ke adm01.
