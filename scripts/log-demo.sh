#!/bin/bash
# log-demo.sh — generator log aplikasi sederhana (Modul 2)
# Lokasi terpasang di srv01: /usr/local/bin/log-demo.sh
LOG=/var/log/demo-app.log
echo "$(date -Is) demo-app: hello from $(hostname) pid=$$" >> "$LOG"
