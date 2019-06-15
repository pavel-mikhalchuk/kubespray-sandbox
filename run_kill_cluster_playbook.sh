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

docker run --rm --network=host -e "USER=${USER}" -v $(pwd)/generated/ssh_keys:/host_ssh kubespray ansible-playbook --become --become-user=root -e reset_confirmation=yes --flush-cache kubespray/reset.yml