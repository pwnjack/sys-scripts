#!/bin/bash

# Replace client_id and client_secret with your actual values
client_id="CLIENT_ID"
client_secret="CLIENT_SECRET"

# Function to obtain the bearer token
get_bearer_token() {
    local response=$(curl -X POST "https://api.eu-1.crowdstrike.com/oauth2/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "client_id=${client_id}" \
        -d "client_secret=${client_secret}" \
        -d "grant_type=client_credentials")

    local bearer_token=$(echo $response | jq -r '.access_token')
    echo $bearer_token
}

# Function to retrieve the host IDs
get_host_ids() {
    local bearer_token=$1
    local response=$(curl -X GET "https://api.eu-1.crowdstrike.com/devices/queries/devices/v1?limit=5000" \
        -H "Authorization: Bearer ${bearer_token}")

    local host_ids=$(echo $response | jq -r '.resources[]')
    echo $host_ids
}

# Function to retrieve the host details for each id
get_host_details() {
    local bearer_token=$1
    local host_ids=$2
    local host_details=""

    for host_id in $host_ids; do
        local response=$(curl -X POST "https://api.eu-1.crowdstrike.com/devices/entities/devices/v2" \
            -H "Authorization: Bearer ${bearer_token}" \
            -H "Content-Type: application/json" \
            -d "{\"ids\":[\"$host_id\"]}")

        host_details="$host_details$(echo $response | jq -r '.resources[0]')\n"
    done
    echo -e $host_details
}

bearer_token=$(get_bearer_token)
host_ids=$(get_host_ids $bearer_token)
host_details=$(get_host_details $bearer_token "$host_ids")

# echo -----
# echo $host_ids
# echo -----
# echo $host_details
# echo -----

# Write the host details to a CSV file
echo "Host ID,Host Name,Operating System,IP Address" > host_details.csv
while read -r line; do
    host_id=$(echo $line | jq -r '.device_id')
    host_name=$(echo $line | jq -r '.hostname')
    os=$(echo $line | jq -r '.os_version')
    ip_address=$(echo $line | jq -r '.local_ip')
    echo "$host_id,$host_name,$os,$ip_address" >> host_details.csv
done <<< "$host_details"
