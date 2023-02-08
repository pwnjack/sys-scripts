#!/bin/bash

# Set SSH credentials for the remote backup server
BCK_SERVER="10.128.0.9"
BCK_USER="backups"
BCK_KEY="$HOME/.ssh/bcksrv_key"
BCK_PATH="/tmp/backups/"

# Set the timestamp variable
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Set the source and destination variables
SOURCE="/opt"

# Create the tar.gz archive with the timestamp
tar -czvf "/tmp/$(hostname)_${TIMESTAMP}.tar.gz" ${SOURCE}

# Encrypt the tar.gz archive
#gpg --pinentry-mode loopback --passphrase INSERT-PASSPHRASE-HERE -c /tmp/$(hostname)_$TIMESTAMP.tar.gz
gpg --batch --yes --passphrase INSERT-PASSPHRASE-HERE -c "/tmp/$(hostname)_${TIMESTAMP}.tar.gz"

# Send the encrypted file to the remote server
scp -i "${BCK_KEY}" "/tmp/$(hostname)_${TIMESTAMP}.tar.gz.gpg" ${BCK_USER}@${BCK_SERVER}:${BCK_PATH}

echo "sending files to backup server... COMPLETED"

# Delete the local copy of the encrypted file
rm -f "/tmp/$(hostname)_$TIMESTAMP.tar.gz*"

echo "deleting temp local archive... COMPLETED"

echo "to decrypt files use: 'gpg -d -o <file>.tar.gz <file>.tar.gz.gpg'"
# Decrypt command: "gpg -d -o <file>.tar.gz <file>.tar.gz.gpg"