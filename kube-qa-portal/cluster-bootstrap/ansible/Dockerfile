FROM ubuntu:16.04

# Ubuntu Packages
RUN apt update -y && \
  apt install -y sudo \
  libssl-dev python-dev sshpass apt-transport-https \
  ca-certificates curl gnupg2 software-properties-common \
  python-pip curl sshpass
# Ubuntu Packages

# Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable" \
  && apt update -y && apt-get install docker-ce -y
# Docker

# Ansible
RUN mkdir /ansible
WORKDIR /ansible

COPY ./requirements.txt ./requirements.txt

RUN /usr/bin/python -m pip install pip -U && \
  /usr/bin/python -m pip install -r requirements.txt
# Ansible

# Copying stuff
COPY . .

ENTRYPOINT [ "scripts/ansible-entrypoint.sh" ]