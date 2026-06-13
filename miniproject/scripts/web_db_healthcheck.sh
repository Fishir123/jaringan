#!/bin/bash
# Cron job 2: health check koneksi web server -> DB remote (cli01)
LOG=/var/log/web_db_health.log
DBHOST=10.20.2.11
TS=$(date '+%F %T')
# cek reachability port 3306 + query ringan
if mysql -h "$DBHOST" -u webapp -p'WebApp#1206' -N -e "SELECT COUNT(*) FROM labapp.visitors;" >/tmp/_hc 2>/dev/null; then
    CNT=$(cat /tmp/_hc)
    echo "$TS UP   DB $DBHOST reachable, visitors=$CNT" >> "$LOG"
else
    echo "$TS DOWN DB $DBHOST tidak bisa diquery dari web server" >> "$LOG"
fi
rm -f /tmp/_hc
