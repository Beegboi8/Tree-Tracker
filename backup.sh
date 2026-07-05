#!/bin/bash

BACKUP_DIR="$(pwd)/backups"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

cp climbs.db "$BACKUP_DIR/climbs_$TIMESTAMP.db"

# Delete backups older than 7 days
find "$BACKUP_DIR" -name "*.db" -mtime +7 -delete

echo "Backup created: climbs_$TIMESTAMP.db" 