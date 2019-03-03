#!/bin/bash

useradd -m ${USER}

echo "$USER ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

# SSH keys
if [ -d "/host_ssh" ];
then
    mkdir -p /home/${USER}/.ssh/

    cp /host_ssh/id_rsa /home/${USER}/.ssh/id_rsa
    chown ${USER}:${USER} /home/${USER}/.ssh/id_rsa
    cp /host_ssh/id_rsa.pub /home/${USER}/.ssh/id_rsa.pub
    chown ${USER}:${USER} /home/${USER}/.ssh/id_rsa.pub
else
    echo "/host_ssh is not provided. Skipping SSH keys step."
fi
# SSH keys

# Kube config
mkdir -p /home/${USER}/.kube/

cp /host_kube_config/config /home/${USER}/.kube/config 2>/dev/null
chown ${USER}:${USER} /home/${USER}/.kube/config 2>/dev/null
# Kube config

# Get permissions for kubespray folder so ansible .retry file can be written 
chown -R ${USER}:${USER} /kubespray

su ${USER} -c '"$0" "$@"' -- "$@" 
