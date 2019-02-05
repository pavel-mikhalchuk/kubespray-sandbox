#!/bin/sh

adduser -D -u ${USER_ID} ${USER}

if getent group ${DOCKER_GROUP_ID} > /dev/null; then
    MOD_GROUP=`getent group ${DOCKER_GROUP_ID} | cut -d: -f1`
    FREE_GROUP_ID=${DOCKER_GROUP_ID}
    while getent group ${FREE_GROUP_ID} > /dev/null; do
        FREE_GROUP_ID=$((FREE_GROUP_ID + 1))
    done
    groupmod -g ${FREE_GROUP_ID} ${MOD_GROUP}
fi

addgroup -g ${DOCKER_GROUP_ID} docker
usermod -aG docker ${USER}

exec su-exec ${USER} $@
