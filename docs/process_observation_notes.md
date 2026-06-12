# Process Observation Notes (srv01)

## Konsep
- **Process** = program berjalan, punya PID (Process ID) dan PPID (parent PID).
- **Daemon** = process yang jalan di background (lepas dari terminal).
- **Service (systemd unit)** = definisi terstruktur cara process dijalankan,
  diawasi, dan di-restart oleh systemd.

## Temuan dari srv01
- **PID 1 = systemd** (init pertama, induk semua proses userland).
- **Parent sshd**: sshd listener dijalankan oleh systemd (PID 1); tiap sesi SSH
  membuat child `sshd-session`.
- Konsumen memori terbesar saat idle: `systemd` (PID 1) ~14 MB RES; sisanya
  kernel thread (RES 0).

## ps vs top vs htop
- `ps` : snapshot sekali (titik waktu), cocok untuk evidence/script.
- `top`: real-time, refresh berkala, ringan, ada di semua sistem.
- `htop`: real-time interaktif (warna, scroll, kill mudah), perlu diinstall.

## Load average (dari stress test)
- 3 angka = rata-rata beban 1 / 5 / 15 menit (jumlah proses runnable/uninterruptible).
- Pada srv01 (2 vCPU): load ~2.0 = CPU penuh terpakai; > 2.0 = ada antrian (bottleneck).
- Saat `stress --cpu 1`: 1 core penuh (%CPU 100), load naik bertahap.

## %CPU vs load average
- `%CPU` (top) = pemakaian CPU sesaat per proses/total.
- `load average` = rata-rata panjang antrian proses dalam rentang waktu.
- Beda kunci: %CPU = snapshot instan; load average = tren beban (termasuk proses
  menunggu I/O pada angka uninterruptible).

## Kapan CPU bottleneck
- load average konsisten > jumlah core, dan %id (idle) mendekati 0,
  serta banyak proses status R (running) mengantri.

Evidence: `evidence/process_snapshot.txt`, `evidence/stress_snapshot.txt`.
