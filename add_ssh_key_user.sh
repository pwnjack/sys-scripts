#!/bin/bash

user_name="USER_NAME"
priv_key='PRIVATE_KEY'

randompw=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)

echo "Creating ${user_name} user..."
sudo adduser ${user_name}
sudo usermod -aG wheel ${user_name}
echo "${randompw}" | sudo -S passwd --stdin ${user_name}
echo "Random password for user ${user_name} set as: ${randompw}"
sudo -i -u ${user_name} bash << EOF
echo "Configuring key..."
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
chmod 755 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
echo "${priv_key}" >> ~/.ssh/authorized_keys
EOF
echo "Completed."
