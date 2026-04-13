#!/bin/bash
STATUS_FILE=/mnt/usbdata/homepage/backup-status.json
mkdir -p /mnt/usbdata/homepage

if [ "$1" = "success" ]; then
  echo "{\"status\": \"OK ✅\", \"last_backup\": \"$(date '+%d.%m.%Y %H:%M')\"}" > "$STATUS_FILE"
else
  echo "{\"status\": \"FEHLER ❌\", \"last_backup\": \"$(date '+%d.%m.%Y %H:%M')\"}" > "$STATUS_FILE"
fi
