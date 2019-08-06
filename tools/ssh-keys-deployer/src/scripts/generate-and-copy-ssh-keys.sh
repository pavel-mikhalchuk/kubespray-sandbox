#!/bin/bash

USER=""

for i in "$@"
do
case $i in
    -u=*|--user=*)
    USER="${i#*=}"
    shift # past argument=value
    ;;
    -p=*|--password=*)
    NODE_PASSWORD="${i#*=}"
    shift # past argument=value
    ;;
    *)
      echo "UKNOWN" # unknown option
    ;;
esac
done

if [[ -z "$USER" ]]; then
    echo "User name is not specified"
    exit 1
fi

if [[ -z "$NODE_PASSWORD" ]]; then
    echo "Password is not specified"
    exit 1
fi

echo "User: $USER"
echo "Pswd: $NODE_PASSWORD"

mkdir ~/.ssh

echo -e 'y\n' | ssh-keygen -b 2048 -t rsa -f "/generated_ssh_key/${USER}_rsa" -q -N ""
echo "Keys are generated"
echo "Now copying keys to nodes..."

for ip in `cat /ssh-keys-deployer/target_hosts`; do
    sshpass -p ${NODE_PASSWORD} ssh-copy-id -o StrictHostKeyChecking=no -i "/generated_ssh_key/${USER}_rsa.pub" ${USER}@$ip
done
