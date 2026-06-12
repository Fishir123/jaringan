# Laporan Modul 3 — Processes, Services, Job Scheduling & Observability

Workshop Administrasi Jaringan · PENS — Teknik Informatika dan Komputer

- Kelompok: X = 2 · Fokus host: **srv01** · Akses: SSH key dari adm01
- OS: Debian 13.4 (trixie) · Tanggal: 2026-06-12

## 1. Ringkasan

Pada srv01 dilakukan observasi proses & resource, pengelolaan service dengan
systemd, pembuatan custom service (`demo-app`), penjadwalan dengan systemd timer
(serta cron sebagai pembanding), dan stress test CPU untuk observability. Semua
artefak diperbarui di repo `lab-admin/`.

## 2. Observasi Proses (4.1)

- PID 1 = **systemd** (induk semua proses userland).
- Parent sshd = systemd; tiap sesi membuat child `sshd-session`.
- `ps` (snapshot) vs `top` (real-time) vs `htop` (interaktif).

Evidence: `evidence/process_snapshot.txt` · Catatan: `docs/process_observation_notes.md`.

## 3. systemd Service Management (4.2 & 4.3)

Custom service `demo-app` dibuat dari `log-demo.sh`:

```
[Service]
Type=simple
ExecStart=/usr/local/bin/log-demo.sh
Restart=on-failure
User=root
```

- `daemon-reload` → `start` → `enable`.
- Status: **enabled** (aktif saat dipanggil, lalu exit 0 — wajar untuk script singkat).
- Log via journald: `journalctl -u demo-app`.

Evidence: `evidence/service_status.txt` · Unit: `configs/demo-app.service`.

## 4. systemd Timer (4.4)

- `demo-app-periodic.timer` (OnBootSec=1min, OnUnitActiveSec=1min) memanggil
  `demo-app-periodic.service` (Type=oneshot).
- Status: **active + enabled**, terlihat di `systemctl list-timers` (NEXT/LAST terisi).
- Terbukti berjalan: `/var/log/demo-app.log` bertambah otomatis tiap menit
  (timestamp baru tiap baris).

Evidence: `evidence/timer_status.txt` · Unit: `configs/demo-app-periodic.timer`, `configs/demo-app-periodic.service`.

## 5. Cron sebagai Pembanding (4.5)

```
*/2 * * * * /usr/local/bin/log-demo.sh
```

Analisis cron vs systemd timer ada di `docs/scheduling_policy_v1.md`
(kelebihan timer: integrasi journal, dependency, status terlihat, persistensi).

## 6. Resource Stress Test (4.6)

- `stress --cpu 1 --timeout 30` → 1 core 100% (%CPU 100 pada proses stress).
- Load average naik (0.34 → 0.60) selama beban.
- Analisis load average & bottleneck: `docs/process_observation_notes.md`.

Evidence: `evidence/stress_snapshot.txt`.

## 7. Definition of Done (Checklist)

| Item | Status |
|------|--------|
| demo-app.service aktif & enable | OK (enabled) |
| demo-app-periodic.timer jalan | OK (active, list-timers terisi) |
| Log terus bertambah otomatis | OK (per menit, timestamp baru) |
| Stress test terbukti & dianalisis | OK |
| Repo terupdate + evidence lengkap | OK |

## 8. Bukti Screenshot

### [1] Observasi proses (PID 1 = systemd, hierarki, konsumen memori)

![Bukti proses](/home/faiqm/Documents/jaringan/modul3/bukti_1_proses.png)

### [2] Custom service demo-app (enabled + journal)

![Bukti service](/home/faiqm/Documents/jaringan/modul3/bukti_2_service.png)

### [3] systemd timer aktif + log tumbuh otomatis per menit

![Bukti timer](/home/faiqm/Documents/jaringan/modul3/bukti_3_timer.png)

### [4] Cron sebagai pembanding

![Bukti cron](/home/faiqm/Documents/jaringan/modul3/bukti_4_cron.png)

### [5] Stress test CPU (proses stress ~100% CPU, load average naik)

![Bukti stress](/home/faiqm/Documents/jaringan/modul3/bukti_5_stress.png)

## 9. Penyimpangan dari Modul

- OS Debian 13 (trixie), bukan Debian 12 — mengikuti ISO yang tersedia.
- User admin `fishir` menggantikan `student`.
