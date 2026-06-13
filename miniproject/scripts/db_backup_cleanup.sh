#!/bin/bash
# Cron job 3: retensi backup 7 hari (DB server adm01)
set -euo pipefail
BACKUP_DIR=/srv/backup/mariadb
LOG=/var/log/db_backup.log
N=$(find "$BACKUP_DIR" -name '*.sql.gz' -mtime +7 -print -delete 2>/dev/null | wc -l)
echo "$(date '+%F %T') CLN hapus $N backup lama (>7 hari)" >> "$LOG"
