#!/bin/bash

USER=""

for i in "$@"
do
case $i in
    -u=*|--user=*)
    USER="${i#*=}"
    shift # past argument=value
    ;;
    *)
      echo "UKNOWN" # unknown option
    ;;
esac
done

if [[ -z "$USER" ]]; then
    USER=infra
fi

echo "User: $USER"

docker run --rm --network=host -e "USER=${USER}" -v $(pwd)/generated/ssh_keys:/host_ssh kube-logging ansible-playbook master_playbook.yml --extra-vars "ansible_user=${USER}"