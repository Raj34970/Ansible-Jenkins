#!/bin/bash

# === CONFIGURATION ===
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="jenkins_backup_$DATE.tar.gz"
RETURN_CODE=0

# loading the .env file
if [ ! -f "$(dirname "$0")/.env" ]; then RETURN_CODE=1; critical "No environment file, use the sample file"; fi
set -a
source "$(dirname "$0")/.env"
set +a

# === PREPARE BACKUP ===
echo "Creating backup of Jenkins home..."
sudo mkdir -p "$BACKUP_DIR"
sudo tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$JENKINS_HOME" .

# === UPLOAD VIA SFTP ===
echo "Sending backup to SFTP server..."
sftp -P $SFTP_PORT "$SFTP_USER@$SFTP_HOST" <<EOF
cd $REMOTE_DIR
put $BACKUP_DIR/$BACKUP_FILE
bye
EOF

# === CLEAN UP ===
echo "Cleaning up local backup..."
sudo rm -f "$BACKUP_DIR/$BACKUP_FILE"

echo "Backup and upload completed successfully!"
