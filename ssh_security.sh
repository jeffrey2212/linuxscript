#!/bin/bash

# Replace these variables as per your requirement
NEW_USER="newusername"
NEW_USER_PASSWORD="newuserpassword"
NEW_SSH_PORT="newsshport" # e.g., 8222
SSH_PUBLIC_KEY="sshpublickey" # Your SSH public key as a string

# Update and Upgrade the System (Optional)
sudo apt update && sudo apt upgrade -y

# Create New User
sudo adduser --gecos "" $NEW_USER --disabled-password
echo "$NEW_USER:$NEW_USER_PASSWORD" | sudo chpasswd

# Grant New User Sudo Privileges
sudo usermod -aG sudo $NEW_USER

# Allow New User to Run Sudo Without a Password
echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# Add SSH Public Key to New User's Authorized Keys
sudo mkdir -p /home/$NEW_USER/.ssh
echo $SSH_PUBLIC_KEY | sudo tee /home/$NEW_USER/.ssh/authorized_keys
sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys
sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh

# Change SSH Port
sudo sed -i "s/#Port 22/Port $NEW_SSH_PORT/g" /etc/ssh/sshd_config

# Disable Root SSH Login
sudo sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
sudo sed -i "s/PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config

# Restart SSH Service
sudo systemctl restart sshd

# Output Completion Message
echo "Setup completed. SSH is now on port $NEW_SSH_PORT. Root login is disabled. $NEW_USER can run sudo without a password."
