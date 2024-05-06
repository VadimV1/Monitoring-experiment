#!/bin/bash

# Check if the user is root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Please login as root and try again."
    exit 1
fi

# Firstly remove any conflicting packages for Docker, like 'containerd' and 'runc' if the exist
echo "Cheking for the existance of 'containerd' and 'runc' to remove them...."
echo ""

packages=("containerd" "runc")

for package in "${packages[@]}"; do
    if dpkg -l | grep -q "$package"; then
        echo "$package is installed. Removing..."
        sudo apt-get remove --purge "$package"
        echo "$package removed."
    else
        echo "$package is not installed."
    fi
done

echo ""
# Secondly remove unofficial distributions of Docker packages in APT

echo "Cheking for unofficial distributions of Docker packages in APT to remove them....."
echo""

packages=("docker.io" "docker-compose" "docker-doc" "docker-doc")

for package in "${packages[@]}"; do
    if dpkg -l | grep -q "$package"; then
        echo "$package is installed. Removing..."
        sudo apt-get remove --purge "$package"
        echo "$package removed."
    else
        echo "$package is not installed."
    fi
done

echo ""

# After checkign and removing the conflicting packages, procced to install the 'Docker engine'

echo "Updating GPG keys and adding the repo into APT sources........"
echo ""

# Add the repository to Apt sources:

apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update


# After initizalizing APT use the command to install
echo "Getting Docker engine versions..."
echo ""
apt-cache madison docker-ce | awk '{ print $3 }'

echo "Please enter the version you would like to isntall: "



read VERSION_STRING

echo "Now installing the 'Docker' engine....."
echo ""


apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
echo ""
echo "Done"


# Now test the 'Docker' is running on the machine 

echo""
echo "Verify that the Docker Engine installation is successful by running 'hello-world' image on 'Docker'..."
echo""

docker run hello-world

echo ""



# After the 'Dcoker' engine is installed, proccced to checking is the comm port is open for k8s and adding the user to the docker group

# First step is to disable swap files

# Check if port 6443 is open
echo "Cheking if port 6443 for K8s communication is opened on the machine..."
echo ""
nc -zv localhost 6443 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Port 6443 is already open."
else
    echo "Port 6443 is closed. Opening port 6443..."
    iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
    echo "Port 6443 opened."
fi

# Get the current user
current_user=$(whoami)

# Add the current user to the Docker group
usermod -aG docker $current_user

# Print a message indicating success
echo "User $current_user added to the Docker group"
echo ""

newgrp docker

echo "Finished the Docker setup"
