#!/bin/bash

# Set the timestamp variable
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Set the source and destination variables
SOURCE="/opt"

# Create the tar.gz archive with the timestamp
tar -czvf /tmp/$(hostname)_$TIMESTAMP.tar.gz $SOURCE

# Encrypt the tar.gz archive
#gpg --pinentry-mode loopback --passphrase INSERT-PASSPHRASE-HERE -c /tmp/$(hostname)_$TIMESTAMP.tar.gz
gpg --batch --yes --passphrase INSERT-PASSPHRASE-HERE -c /tmp/$(hostname)_$TIMESTAMP.tar.gz

# Send the encrypted file to the remote server
scp -i ~/.ssh/bck_key /tmp/$(hostname)_$TIMESTAMP.tar.gz.gpg backups@10.128.0.9:/exporter_IN/backups

# Delete the local copy of the encrypted file
rm /tmp/$(hostname)_$TIMESTAMP.tar.gz*

# decrypt command "gpg -d -o <file>.tar.gz <file>.tar.gz.gpg"