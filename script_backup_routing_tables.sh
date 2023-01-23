#!/bin/bash

# Set the timestamp variable
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Read the list of systems from the systems.txt file
readarray -t systems < ~/backup_routing_tables/systems.txt

mkdir ~/backup_routing_tables/routing_tables_$TIMESTAMP

# Loop through the list of systems
for system in "${systems[@]}"
do
    # Export the routing table from the remote system
    ssh -i ~/.ssh/of_key cloud-user@$system "netstat -rn" > ~/backup_routing_tables/routing_tables_$TIMESTAMP/$system.txt

    # Print a message to confirm the export
    echo "Routing table exported from $system"
done

scp -i ~/.ssh/bck_key -r ~/backup_routing_tables/routing_tables_$TIMESTAMP backups@10.128.0.9:/exporter_IN/backups/

echo "sending files to backup server... COMPLETED"