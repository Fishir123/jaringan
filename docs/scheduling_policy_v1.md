# Scheduling Policy v1

## Kapan gunakan cron
- Tugas sederhana, berkala, tanpa dependency antar-service.
- Skrip ringkas yang sudah menangani log/error sendiri.
- Kompatibilitas lintas sistem Unix non-systemd.

## Kapan gunakan systemd timer
- Butuh dependency (`After=`, `Requires=`) ke service/target lain.
- Butuh integrasi journal (`journalctl -u`) untuk audit & troubleshooting.
- Butuh fitur lanjut: `OnBootSec`, `OnUnitActiveSec`, randomized delay,
  persistensi (`Persistent=true`), resource control (cgroups).
- Eksekusi sebagai service yang dapat dimonitor statusnya.

## Kelebihan systemd timer dibanding cron
- Log eksekusi otomatis masuk journald (cron perlu setup MAILTO/redirect).
- Status terlihat: `systemctl list-timers`, `systemctl status`.
- Bisa mengikat dependency dan urutan boot.
- Penanganan miss-run (`Persistent=true`) saat sistem mati.

## Aturan wajib
- DILARANG menjalankan script terjadwal tanpa logging. Setiap job harus
  menulis output/errornya (ke file atau journald) agar dapat diaudit.
- Setiap job terjadwal harus tercatat di change_log + runbook.
- Untuk lab ini, penjadwalan utama memakai **systemd timer**; cron hanya
  sebagai pembanding analitis.

## Implementasi di srv01
- systemd timer: `demo-app-periodic.timer` → tiap 1 menit (OnUnitActiveSec=1min).
- cron (pembanding): `*/2 * * * * /usr/local/bin/log-demo.sh` (crontab user fishir).
