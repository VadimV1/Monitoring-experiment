#!/bin/bash



# Check if the user is root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Please login as root and try again."
    exit 1
fi

rm -r /etc/kubernetes/ssl
rm -r /var/lib/etcd
rm -r /etc/cni
rm -r /opt/cni
rm -r /var/run/calico
