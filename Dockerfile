FROM kylemanna/openvpn:latest

ARG K8S_VERSION=v1.3.6

RUN wget https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/

ADD gh-dl-release /bin/
RUN chmod +x /bin/gh-dl-release

ARG GITHUB_TOKEN
ARG REPO=cloudposse/github-pam
ARG FILE=github-pam_linux_386
ARG VERSION=0.4

RUN if [ ! -z $GITHUB_TOKEN ]; then \
      set -ex \
      && apk add --no-cache --virtual .build-deps \
		    curl \
		    jq \
		  && gh-dl-release $VERSION github-pam-plugin \
      && chmod +x github-pam-plugin \
      && mv github-pam-plugin /bin/ \
      && apk add ca-certificates \
      && apk del .build-deps; \
    else \
      echo '`GITHUB_TOKEN` required for fetching github-pam-plugin'; \
      exit 1; \
    fi

ADD save_secrets /bin/
RUN chmod +x /bin/save_secrets