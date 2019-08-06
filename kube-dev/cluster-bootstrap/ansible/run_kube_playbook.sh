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

GROUP=${USER}

USER_ID=$(id -u ${USER}) || { echo "You should have user ${USER} created on your machine" ; exit 1; }
GROUP_ID=$(id -g ${GROUP}) || { echo "You should have group ${GROUP} created on your machine" ; exit 1; }

echo "User: ${USER}"
echo "User ID: ${USER_ID}"
echo "Group: ${GROUP}"
echo "Group ID: ${GROUP_ID}"

docker run --rm --network=host \
  -e "USER=${USER}" \
  -e "USER_ID=${USER_ID}" \
  -e "GROUP=${GROUP}" \
  -e "GROUP_ID=${GROUP_ID}" \
  -v $(pwd)/generated/kube_files:/kubespray/artifacts \
  kubespray \
  ansible-playbook kube.yml