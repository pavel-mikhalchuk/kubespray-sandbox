FROM ubuntu:16.04

# Ubuntu Packages
RUN apt update -y && \
  apt install -y sudo \
  libssl-dev python-dev sshpass apt-transport-https \
  ca-certificates curl gnupg2 software-properties-common \
  python-pip curl sshpass
# Ubuntu Packages

# SSH Keys Deployer
RUN mkdir /ssh-keys-deployer
WORKDIR /ssh-keys-deployer

COPY . .

ENTRYPOINT [ "scripts/docker-entrypoint.sh" ]