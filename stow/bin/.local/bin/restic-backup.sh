#!/usr/bin/env bash
# Backup de $HOME a disco local via restic. Corrido por restic-backup.timer (systemd --user).
set -euo pipefail

export RESTIC_REPOSITORY="/mnt/Elements/restic-backup"
export RESTIC_PASSWORD_FILE="$HOME/.config/restic/password"
EXCLUDES="$HOME/.config/restic/excludes.txt"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/restic/backup.log"
mkdir -p -- "$(dirname -- "$LOG")"

if ! mountpoint -q /mnt/Elements; then
  echo "$(date --iso-8601=seconds) SKIP: /mnt/Elements no montado" >>"$LOG"
  exit 0
fi

{
  date --iso-8601=seconds
  backup_rc=0
  restic backup "$HOME" --exclude-file="$EXCLUDES" --exclude-caches --one-file-system || backup_rc=$?
  # exit 3 = snapshot creado pero algunos archivos no se pudieron leer (permisos, etc): no fatal, seguir con forget.
  if [[ "$backup_rc" -ne 0 && "$backup_rc" -ne 3 ]]; then
    echo "restic backup falló (exit=$backup_rc), aborto sin prune"
    exit "$backup_rc"
  fi
  restic forget --keep-weekly 8 --keep-monthly 12 --keep-yearly 2 --prune
  echo "exit=$backup_rc"
} >>"$LOG" 2>&1
