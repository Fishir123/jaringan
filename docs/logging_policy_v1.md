# Logging Policy v1

## Sumber log
- **journald** (systemd journal): log boot, kernel, dan service (mis. ssh).
- **/var/log**: log berbasis file via rsyslog + log aplikasi (mis. `demo-app.log`).

## Retensi
- Demo aplikasi: `demo-app.log` di-rotate harian, simpan 7 hari (`rotate 7`),
  `compress` + `delaycompress`, `copytruncate` (aman untuk app yang menulis terus).
- Retensi dapat diubah sesuai kebutuhan layanan nanti.

## Prosedur "cek error cepat" (3 command journalctl penting)
```
sudo journalctl -p err -b --no-pager        # semua error sejak boot ini
sudo journalctl -u ssh -b --no-pager        # log service tertentu (ssh)
sudo journalctl -xe --no-pager               # error terbaru + konteks
```

## Logrotate
- File konfigurasi demo: `/etc/logrotate.d/demo-app` (lihat configs/logrotate_demo.conf).
- Uji paksa: `sudo logrotate -f /etc/logrotate.d/demo-app`.
- Bukti rotate: `demo-app.log` (0 byte setelah copytruncate) + `demo-app.log.1`.

## Prinsip
Log adalah alat forensik. Kalau log berantakan atau hilang, troubleshooting
jadi spekulasi. Maka log harus terstruktur, ter-rotate, dan retensinya jelas.

## Bukti
`evidence/logging_tests_srv01.txt`, `evidence/storage_logging_evidence_srv01.txt`.
