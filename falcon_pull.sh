#!/bin/bash

# Replace client_id and client_secret with your actual values
client_id="CLIENT_ID"
client_secret="CLIENT_SECRET"

timestamp=$(date +%Y%m%d)

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
    local host_ids_array=(${host_ids[0]})
    
    joined=$(printf ", \"%s\"" "${host_ids_array[@]}")

    local response=$(curl -X POST "https://api.eu-1.crowdstrike.com/devices/entities/devices/v2" \
        -H "Authorization: Bearer ${bearer_token}" \
        -H "Content-Type: application/json" \
        -d "{\"ids\":[${joined:1}]}")
    
    n_host=${#host_ids_array[@]}
    
    for (( ir=0; ir<${n_host}; ir++ )); do
        host_details="$host_details$(echo $response | jq -r --argjson index $ir '.resources[$index]')\n"
    done

    echo -e $host_details
}

bearer_token=$(get_bearer_token)
host_ids=$(get_host_ids $bearer_token)
host_details=$(get_host_details $bearer_token "$host_ids")

# Write the host details to a CSV file
echo "Host ID,Host Name,Operating System,Kernel Version,Local IP, External IP, Mac Address, Machine Domain" > host_details_${timestamp}.csv
while read -r line; do
    device_id=$(echo $line | jq -r '.device_id')
    host_name=$(echo $line | jq -r '.hostname')
    os=$(echo $line | jq -r '.os_version')
    kernel_version=$(echo $line | jq -r '.kernel_version')
    local_ip=$(echo $line | jq -r '.local_ip')
    external_ip=$(echo $line | jq -r '.external_ip')
    mac_address=$(echo $line | jq -r '.mac_address')
    machine_domain=$(echo $line | jq -r '.machine_domain')
    echo "$device_id,$host_name,$os,$kernel_version,$local_ip,$external_ip,$mac_address,$machine_domain" >> host_details_${timestamp}.csv
done <<< "$host_details"
