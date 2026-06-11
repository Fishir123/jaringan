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
