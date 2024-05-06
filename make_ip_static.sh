#!/bin/bash

# Get the current local IP address
current_ip=$(hostname -I | awk '{print $1;exit}')

# Get the network interface name
interface=$(ip route get 1 | awk '{print $5;exit}')

# Create a backup of the current network configuration file
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak

# Create a new netplan configuration file
sudo tee /etc/netplan/01-static-ip.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
      addresses: [$current_ip/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [192.168.1.143, 8.8.4.4]
EOF

# Apply the new network configuration
sudo netplan apply

echo "Static IP address has been configured to: $current_ip"
