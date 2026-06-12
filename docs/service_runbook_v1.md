# Service Runbook v1 — demo-app (srv01)

Runbook operasional untuk service `demo-app` dan timer `demo-app-periodic`.

## Komponen
- `/usr/local/bin/log-demo.sh` — script penulis log.
- `/etc/systemd/system/demo-app.service` — service utama (Type=simple, Restart=on-failure).
- `/etc/systemd/system/demo-app-periodic.service` — service oneshot dipanggil timer.
- `/etc/systemd/system/demo-app-periodic.timer` — timer (tiap 1 menit).
- Output log: `/var/log/demo-app.log`.

## Start / Stop / Restart demo-app
```
sudo systemctl start demo-app
sudo systemctl stop demo-app
sudo systemctl restart demo-app
sudo systemctl status demo-app
```
Catatan: demo-app menulis 1 baris lalu exit (status 0). Untuk penulisan
berkala gunakan timer (di bawah), bukan service utama.

## Cek log
```
journalctl -u demo-app -n 20 --no-pager        # log service via journald
journalctl -u demo-app-periodic -n 20          # log eksekusi timer
tail -f /var/log/demo-app.log                  # isi log aplikasi
```

## Cek timer
```
systemctl list-timers --no-pager | grep demo-app
systemctl status demo-app-periodic.timer
sudo systemctl enable --now demo-app-periodic.timer   # aktifkan
sudo systemctl disable --now demo-app-periodic.timer  # matikan
```

## Troubleshooting umum
- Setelah mengubah unit file: WAJIB `sudo systemctl daemon-reload`.
- Service gagal start: `systemctl status <unit>` + `journalctl -u <unit> -xe`.
- Permission unit file harus `644` root:root; script `755` dan executable.
- Timer "enabled" tapi tidak jalan: pastikan `enable --now`, cek `list-timers`
  ada NEXT/LAST, dan service yang dipanggil (`Unit=`) valid.
- Log tidak bertambah: cek timer aktif dan `ExecStart` menunjuk script benar.
