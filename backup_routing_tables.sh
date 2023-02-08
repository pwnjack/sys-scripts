#!/bin/bash

# Set the path to the file containing the list of target systems
SYSTEM_LIST="$HOME/routing_tables/systems.txt"

# Set SSH credentials to login into remote target systems
SSH_USER="USER_NAME"
SSH_KEY="$HOME/.ssh/sys_key"

# Set SSH credentials for the remote backup server
BCK_SERVER="10.128.0.9"
BCK_USER="backups"
BCK_KEY="$HOME/.ssh/bcksrv_key"
BCK_PATH="/tmp/backups/"

# Set the timestamp variable
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Read the list of systems from the systems.txt file
readarray -t systems < "${SYSTEM_LIST}"

mkdir "$HOME/routing_tables/routing_tables_${TIMESTAMP}"

# Loop through the list of systems
for system in "${systems[@]}"
do
    # Export the routing table from the remote system
    ssh -i "${SSH_KEY}" ${SSH_USER}@$system "netstat -rn" > "$HOME/routing_tables/routing_tables_${TIMESTAMP}/$system.txt"

    # Print a message to confirm the export
    echo "Routing table exported from $system"
done

scp -i "${BCK_KEY}" -r "$HOME/routing_tables/routing_tables_${TIMESTAMP}" ${BCK_USER}@${BCK_SERVER}:${BCK_PATH}

echo "sending files to backup server... COMPLETED"