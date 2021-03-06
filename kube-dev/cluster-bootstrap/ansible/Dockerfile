FROM alpine:3.8

RUN apk add --no-cache --update \
        build-base curl bash \
        ca-certificates openssh-client openssl-dev \
        python py-pip python-dev libffi-dev \
 && pip install --no-cache --upgrade pip==18.1 \
 && pip install --no-cache --upgrade \
        ansible \
        pyhelm \
        openshift  \
 && rm -rf /var/cache/apk/*

ARG KUBECTL_VERSION=v1.13.1
ENV KUBECTL_URL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl

RUN set -xe \
 && curl -Lo /usr/bin/kubectl ${KUBECTL_URL} \
 && chmod +x /usr/bin/kubectl

ARG HELM_VERSION=v2.12.0
ENV HELM_URL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz

RUN curl -Lo /tmp/helm.tar.gz ${HELM_URL} \
  && tar -zxvf /tmp/helm.tar.gz -C /tmp \
  && mv /tmp/linux-amd64/helm /usr/bin/helm \
  && rm -rf /tmp/*

RUN apk --no-cache add shadow su-exec git python3

COPY scripts/infra-tools-entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
