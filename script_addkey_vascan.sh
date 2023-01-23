#!/bin/bash

randompw=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)

echo "Creating vascan user..."
sudo adduser vascan
sudo usermod -aG wheel vascan
echo $randompw | sudo -S passwd --stdin vascan
echo "Random password for user vascan set as: $randompw"
sudo -i -u vascan bash << EOF
echo "Configuring key..."
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
chmod 755 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
echo "ssh-rsa INSERT-PRIVATE-SSH-KEY-HERE" >> ~/.ssh/authorized_keys
EOF
echo "Completed."