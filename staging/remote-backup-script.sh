#!/bin/bash

# set variables
HOSTS_FILE="hosts.txt"
PASSPHRASE="mysecretpassphrase"
TIMESTAMP="$(date +%Y-%m-%d-%H-%M-%S)"
EXCLUDE_FILE="exclude-list.txt"

# loop through hosts in hosts.txt file
while read -r line; do
  # extract ssh connection string and source directory from line
  ssh_conn=$(echo "${line}" | cut -d ' ' -f 1)
  src_dir=$(echo "${line}" | cut -d ' ' -f 2)

  # get hostname from remote host
  host_name=$(ssh -n "${ssh_conn}" hostname)

  # set backup filename
  backup_file="${host_name}-${TIMESTAMP}.tar.gz.gpg"

  # create local backup directory
  mkdir -p "backups/${host_name}"

  # rsync backup of specified directory from remote host, excluding files listed in exclude-list.txt
  rsync -av --delete --exclude-from="${EXCLUDE_FILE}" -e "ssh" "${ssh_conn}:${src_dir}" "backups/${host_name}/"

  # compress backup directory and encrypt it with gpg using passphrase
  tar -czf - "backups/${host_name}/" | gpg --batch --symmetric --passphrase "${PASSPHRASE}" -o "backups/${host_name}/${backup_file}"

  # remove temporary backup directory
  rm -rf "backups/${host_name}/"

  # print confirmation message
  echo "Backup of ${ssh_conn}:${src_dir} completed and saved as backups/${host_name}/${backup_file}"
done < "${HOSTS_FILE}"

# Restore instructions
echo ""
echo "To restore a backup, copy the encrypted backup file to the remote host and run the following command:"
echo "gpg --batch --decrypt --passphrase ${PASSPHRASE} ${backup_file} | tar -xz -C /destination/directory/"
