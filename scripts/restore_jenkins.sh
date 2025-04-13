#!/bin/bash

if [ ! -f "$(dirname "$0")/.env" ]; then RETURN_CODE=1; critical "No environment file, use the sample file"; fi
set -a

source "$(dirname "$0")/.env"
set +a

# Check if a date argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 YYYY-MM-DD (e.g., $0 2025-02-23)"
    exit 1
fi

RESTORE_DATE="$1"

# === CONFIGURATION ===
BACKUP_FILE="jenkins_backup_$RESTORE_DATE.tar.gz" 

# === STOP JENKINS SERVICE ===
echo "Stopping Jenkins..."
sudo systemctl stop jenkins

# === CREATE RESTORE DIRECTORY ===
mkdir -p "$RESTORE_DIR"
cd "$RESTORE_DIR"

# === DOWNLOAD BACKUP FROM SFTP ===
echo "Downloading backup file from SFTP..."
sftp -P $SFTP_PORT "$SFTP_USER@$SFTP_HOST" <<EOF
cd $REMOTE_DIR
get $BACKUP_FILE
bye
EOF

# === BACKUP CURRENT JENKINS HOME (JUST IN CASE) ===
echo "Backing up current Jenkins home..."
sudo tar -czf "/tmp/jenkins_current_backup_$(date +'%F_%H-%M-%S').tar.gz" -C "$JENKINS_HOME" .

# === RESTORE BACKUP ===
echo "Restoring backup to Jenkins home..."
sudo tar -xzf "$BACKUP_FILE" -C "$JENKINS_HOME"

# === FIX PERMISSIONS (if needed) ===
echo "Setting permissions..."
sudo chown -R jenkins:jenkins "$JENKINS_HOME"

# === START JENKINS SERVICE ===
echo "Starting Jenkins..."
sudo systemctl start jenkins

# === CLEAN UP ===
echo "Cleaning up..."
rm -f "$RESTORE_DIR/$BACKUP_FILE"

echo "Restore complete!"
