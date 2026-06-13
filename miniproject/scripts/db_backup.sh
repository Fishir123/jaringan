#!/bin/bash
# Cron job 1: backup harian database labapp (DB server adm01)
set -euo pipefail
BACKUP_DIR=/srv/backup/mariadb
LOG=/var/log/db_backup.log
DB=labapp
TS=$(date +%F_%H%M%S)
mkdir -p "$BACKUP_DIR"
OUT="$BACKUP_DIR/${DB}_${TS}.sql.gz"
if mysqldump --single-transaction --routines --databases "$DB" 2>>"$LOG" | gzip > "$OUT"; then
    echo "$(date '+%F %T') OK  backup -> $OUT ($(du -h "$OUT" | cut -f1))" >> "$LOG"
else
    echo "$(date '+%F %T') ERR backup gagal" >> "$LOG"
    rm -f "$OUT"
    exit 1
fi
