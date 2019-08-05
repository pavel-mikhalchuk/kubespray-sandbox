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

mkdir -p $(pwd)/generated/ssh_keys

docker run --rm --network=host -e "USER=${USER}" -v $(pwd)/generated/ssh_keys:/generated_ssh_key ssh-keys-deployer sh -c "scripts/copy-ssh-keys.sh -u=${USER} -p=${NODE_PASSWORD}"