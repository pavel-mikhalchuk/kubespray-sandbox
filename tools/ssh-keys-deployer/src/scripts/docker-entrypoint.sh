#!/bin/bash
groupadd --gid ${GROUP_ID} ${GROUP}
useradd --create-home --uid ${USER_ID} --gid ${GROUP_ID} ${USER}

echo "$USER ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

echo "Hostname: $(hostname)"

# Give ${USER} write access to keys output dir 
chown -R ${USER}:${USER} /generated_ssh_key

su ${USER} -c '"$0" "$@"' -- "$@" 