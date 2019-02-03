#!/bin/bash
for ip in `cat ./hosts_where_to_copy_ssh_keys`; do
    ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
done
