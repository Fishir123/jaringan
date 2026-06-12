# Change Log

Format: tanggal · host · perubahan · alasan · rollback

## 2026-06-11

1. Host (VirtualBox) · vboxnet0 diset ke 10.10.2.1/24 dan DHCP host-only dimatikan.
   - Alasan: menyesuaikan IP plan modul (10.10.X.0/24, X=2) dan menegakkan IP statik LAN.
   - Rollback: `VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1`; aktifkan kembali DHCP bila perlu.
   - Catatan: rentang 10.10.0.0/16 diizinkan via /etc/vbox/networks.conf.

2. adm01/srv01/cli01 · /etc/apt/sources.list diganti dari cdrom ke repo online trixie.
   - Alasan: instalasi netinst menyetel cdrom sebagai sumber apt sehingga `apt update` gagal dan openssh-server tidak bisa dipasang.
   - Rollback: kembalikan baris `deb cdrom:...` (atau jalankan `apt-cdrom add`).

3. adm01/srv01/cli01 · install openssh-server + git vim curl wget net-tools dnsutils; enable ssh.
   - Alasan: SSH server wajib (modul 7.2/7.4); paket utilitas dasar untuk operasi & verifikasi.
   - Rollback: `apt-get remove --purge openssh-server`.

4. adm01/srv01/cli01 · konfigurasi IP statik LAN enp0s8 via /etc/network/interfaces.d/lan0 (.10/.11/.12).
   - Alasan: LAN internal statik sesuai IP plan.
   - Rollback: hapus file lan0 lalu `systemctl restart networking`.

5. adm01 · generate SSH key ed25519 (adm01@lab2) dan pasang pubkey ke srv01 + cli01.
   - Alasan: akses admin aman berbasis key (modul 7.6).
   - Rollback: hapus entry pubkey dari ~/.ssh/authorized_keys di srv01/cli01.

6. srv01/cli01 · hardening sshd via /etc/ssh/sshd_config.d/99-hardening.conf (PermitRootLogin no, PasswordAuthentication no, PubkeyAuthentication yes).
   - Alasan: baseline keamanan (modul 7.7). Diterapkan SETELAH key login terverifikasi → tidak terkunci.
   - Rollback: hapus 99-hardening.conf lalu `systemctl restart ssh`.

## 2026-06-11 — Modul 2 (System Components, fokus srv01)

7. srv01 (hypervisor) · tambah disk kedua VDI 8 GB ke SATA port 1.
   - Alasan: storage data layanan terpisah dari OS.
   - Rollback: `VBoxManage storageattach srv01 --storagectl SATA --port 1 --device 0 --medium none` lalu hapus srv01_data.vdi.

8. srv01 · partisi /dev/sdb (1 primary) + format ext4 (/dev/sdb1).
   - Alasan: siapkan filesystem untuk /srv/data.
   - Rollback: `wipefs -a /dev/sdb` (menghapus data — hati-hati).

9. srv01 · /etc/fstab tambah mount /srv/data via UUID (defaults,noatime 0 2).
   - Alasan: mount persisten & stabil (UUID bukan /dev/sdb1). Diuji `umount`+`mount -a` sukses.
   - Rollback: hapus baris UUID di /etc/fstab lalu `umount /srv/data`.

10. srv01 · struktur /srv/data/{apps,backup,logs} + grup ops + permission (apps 2775 root:ops).
    - Alasan: standar direktori data & permission aman (bukan 777). fishir masuk grup ops.
    - Rollback: `rm -rf /srv/data/{apps,backup,logs}`, `groupdel ops`.

11. srv01 · install baseline paket (rsyslog logrotate htop tree + utilitas Modul 1).
    - Alasan: standar paket server + tooling logging/observasi.
    - Rollback: `apt-get remove --purge rsyslog logrotate htop tree`.

12. srv01 · logrotate demo: /usr/local/bin/log-demo.sh + /etc/logrotate.d/demo-app.
    - Alasan: membuktikan log aplikasi ter-rotate (daily, rotate 7, copytruncate).
    - Rollback: hapus kedua file dan /var/log/demo-app.log*.

## 2026-06-12 — Modul 3 (Processes, Services, Scheduling, Observability — srv01)

13. srv01 · buat custom service /etc/systemd/system/demo-app.service (Type=simple, Restart=on-failure), enable.
    - Alasan: ubah log-demo jadi service terkelola systemd.
    - Rollback: `systemctl disable --now demo-app` lalu hapus unit + daemon-reload.

14. srv01 · buat systemd timer demo-app-periodic.service + .timer (tiap 1 menit), enable --now.
    - Alasan: penjadwalan modern dengan integrasi journal & dependency.
    - Rollback: `systemctl disable --now demo-app-periodic.timer` lalu hapus unit + daemon-reload.

15. srv01 · tambah cron user fishir `*/2 * * * * /usr/local/bin/log-demo.sh` (pembanding).
    - Alasan: perbandingan analitis cron vs systemd timer.
    - Rollback: `crontab -e` hapus baris log-demo.

16. srv01 · install paket `stress` + jalankan stress test CPU 30s (observability).
    - Alasan: demonstrasi load average & bottleneck CPU.
    - Rollback: `apt-get remove --purge stress`.

## 2026-06-12 — Modul 4 (Networking: routing & packet analysis)

17. Hypervisor · buat host-only vboxnet1 (10.20.2.254/24, DHCP off) + izinkan 10.20.0.0/16 di networks.conf.
    - Alasan: subnet kedua (LAN-B) untuk skenario routing.
    - Rollback: `VBoxManage hostonlyif remove vboxnet1`; hapus baris di /etc/vbox/networks.conf.

18. srv01 · tambah NIC3 (host-only vboxnet1) + konfigurasi enp0s9 10.20.2.1/24 (/etc/network/interfaces.d/lanB).
    - Alasan: srv01 jadi router dengan kaki di LAN-A & LAN-B.
    - Rollback: hapus file lanB + lepas NIC3 di hypervisor.

19. cli01 · pindah NIC2 ke vboxnet1; IP jadi 10.20.2.2/24 gateway 10.20.2.1.
    - Alasan: cli01 pindah ke LAN-B, pakai srv01 sebagai gateway.
    - Rollback: kembalikan adapter ke vboxnet0 + IP 10.10.2.12.

20. srv01 · enable IP forwarding permanen (/etc/sysctl.d/99-router.conf, net.ipv4.ip_forward=1).
    - Alasan: meneruskan paket antar subnet.
    - Rollback: hapus file lalu `sysctl --system`.

21. adm01 · static route 10.20.2.0/24 via 10.10.2.11 (post-up di interfaces.d/lan0).
    - Alasan: adm01 (LAN-A) bisa menjangkau LAN-B via router srv01.
    - Rollback: hapus baris post-up; `ip route del 10.20.2.0/24`.

22. srv01 · install tcpdump; capture ICMP & TCP handshake sebagai evidence.
    - Alasan: packet analysis (membaca echo request/reply & SYN/SYN-ACK/ACK).
    - Rollback: `apt-get remove --purge tcpdump`.
