#!/bin/bash

USER=""

for i in "$@"
do
case $i in
    -u=*|--user=*)
    USER="${i#*=}"
    GROUP=${USER}
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

USER_ID=$(id -u ${USER}) || { echo "You should have user ${USER} created on your machine" ; exit 1; }
GROUP_ID=$(id -g ${GROUP}) || { echo "You should have group ${GROUP} created on your machine" ; exit 1; }

docker run --rm  --network=host -it \
  -e "USER=${USER}" \
  -e "USER_ID=${USER_ID}" \
  -e "GROUP=${GROUP}" \
  -e "GROUP_ID=${GROUP_ID}" \
  -v $(pwd)/generated/ssh_keys:/generated_ssh_key \
  ssh-keys-deployer \
  sh -c "scripts/copy-ssh-keys.sh -u=${USER} -p=${NODE_PASSWORD}"