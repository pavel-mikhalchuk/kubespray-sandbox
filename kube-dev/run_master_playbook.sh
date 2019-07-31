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

mkdir -p $(pwd)/generated/kube_files

docker run --rm --network=host -e "USER=${USER}" -v $(pwd)/generated/ssh_keys:/host_ssh -v $(pwd)/generated/kube_files:/kubespray/artifacts kubespray ansible-playbook --become --become-user=root master_playbook.yml