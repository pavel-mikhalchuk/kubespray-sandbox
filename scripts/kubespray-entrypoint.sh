#!/bin/sh

useradd -m ${USER}

mkdir -p /home/${USER}/.ssh/

cp /host_ssh/id_rsa /home/${USER}/.ssh/id_rsa
chown ${USER}:${USER} /home/${USER}/.ssh/id_rsa
cp /host_ssh/id_rsa.pub /home/${USER}/.ssh/id_rsa.pub
chown ${USER}:${USER} /home/${USER}/.ssh/id_rsa.pub
chown -R ${USER}:${USER} /kubespray

su ${USER} -c '"$0" "$@"' -- "$@" 
