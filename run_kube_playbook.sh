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

docker run --rm --network=host -e "USER=${USER}" -v $(pwd)/generated/kube_files:/host_kube_config kubespray ansible-playbook kube.yml