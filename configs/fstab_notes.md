# fstab notes — srv01 (Modul 2)

Disk kedua `/dev/sdb` (8 GB) ditambahkan ke srv01 di hypervisor (SATA port 1),
dipartisi 1 primary, diformat ext4, dan dimount persisten ke `/srv/data`.

## Entri /etc/fstab (wajib UUID, bukan /dev/sdb1)

```
UUID=bf696e46-2255-4dca-ab49-9c7d617a93b3 /srv/data ext4 defaults,noatime 0 2
```

Alasan pakai UUID: nama device (`/dev/sdb1`) bisa berubah urutannya saat boot
atau saat disk ditambah/dilepas, sehingga mount bisa salah/gagal. UUID stabil
mengikat ke filesystem-nya.

Opsi mount:
- `defaults` = rw, suid, dev, exec, auto, nouser, async.
- `noatime` = tidak menulis waktu akses tiap baca file → kurangi I/O, baik untuk data layanan.
- field ke-5 `0` = tidak di-dump.
- field ke-6 `2` = fsck dijalankan setelah root (`1`).

## Cara ambil UUID

```
sudo blkid /dev/sdb1
# atau
sudo blkid -s UUID -o value /dev/sdb1
```

## Uji tanpa reboot (wajib lulus)

```
sudo umount /srv/data
sudo mount -a
df -hT | grep /srv/data
```

Hasil: `mount -a` sukses, `/srv/data` ter-mount kembali otomatis dari fstab.

## Struktur & permission

```
/srv/data            drwxr-xr-x root:root  (755)
/srv/data/apps       drwxrwsr-x root:ops   (2775, setgid)
/srv/data/backup     drwxr-xr-x root:root  (755)
/srv/data/logs       drwxr-xr-x root:root  (755)
```

Bit setgid (2) pada `apps` membuat file baru mewarisi grup `ops` →
kolaborasi service operators tanpa perlu chmod 777.
