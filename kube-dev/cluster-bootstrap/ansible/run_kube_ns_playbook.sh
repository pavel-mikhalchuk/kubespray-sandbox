#!/bin/bash

USER=""

for i in "$@"
do
case $i in
    -u=*|--user=*)
    USER="${i#*=}"
    shift # past argument=value
    ;;
    -ns=*|--name-space=*)
    NAMESPACE="${i#*=}"
    shift # past argument=value
    ;;
    -dru=*|--docker-registry-user=*)
    DOCKER_REGISTRY_USER="${i#*=}"
    shift # past argument=value
    ;;
    -drp=*|--docker-registry-password=*)
    DOCKER_REGISTRY_PASSWORD="${i#*=}"
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

if [[ -z "$NAMESPACE" ]]; then
    echo "Namespace is not specified"
    exit 1
fi

if [[ -z "$DOCKER_REGISTRY_USER" ]]; then
    echo "Docker registry user name is not specified"
    exit 1
fi

if [[ -z "$DOCKER_REGISTRY_PASSWORD" ]]; then
    echo "Docker registry password is not specified"
    exit 1
fi

GROUP=${USER}

USER_ID=$(id -u ${USER}) || { echo "You should have user ${USER} created on your machine" ; exit 1; }
GROUP_ID=$(id -g ${GROUP}) || { echo "You should have group ${GROUP} created on your machine" ; exit 1; }

echo "User: ${USER}"
echo "User ID: ${USER_ID}"
echo "Group: ${GROUP}"
echo "Group ID: ${GROUP_ID}"
echo "NS: $NAMESPACE"
echo "Docker registry user: $DOCKER_REGISTRY_USER"
echo "Docker registry password: $DOCKER_REGISTRY_PASSWORD"

docker run --rm --network=host \
  -e "USER=${USER}" \
  -e "USER_ID=${USER_ID}" \
  -e "GROUP=${GROUP}" \
  -e "GROUP_ID=${GROUP_ID}" \
  -v $(pwd)/generated/ssh_keys:/host_ssh \
  kubespray \
  ansible-playbook --become --become-user=root kube-ns.yml \
  --extra-vars "ns=${NAMESPACE} docker_registry_username=${DOCKER_REGISTRY_USER} docker_registry_pwd=${DOCKER_REGISTRY_PASSWORD}"