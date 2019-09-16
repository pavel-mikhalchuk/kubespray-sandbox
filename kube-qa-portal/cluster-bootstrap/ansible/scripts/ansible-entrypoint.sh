#!/bin/bash

useradd -m ${USER}

echo "$USER ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

echo "Hostname: $(hostname)"

# SSH keys
if [ -d "/host_ssh" ];
then
    mkdir -p /home/${USER}/.ssh/

    cp /host_ssh/${USER}_rsa /home/${USER}/.ssh/id_rsa || exit 1
    chown ${USER}:${USER} /home/${USER}/.ssh/id_rsa || exit 1
    cp /host_ssh/${USER}_rsa.pub /home/${USER}/.ssh/id_rsa.pub || exit 1
    chown ${USER}:${USER} /home/${USER}/.ssh/id_rsa.pub || exit 1
else
    echo "/host_ssh is not provided. Skipping SSH keys step."
fi
# SSH keys

# Get permissions for ansible folder so ansible .retry file can be written 
chown -R ${USER}:${USER} /ansible

su ${USER} -c '"$0" "$@"' -- "$@" 
