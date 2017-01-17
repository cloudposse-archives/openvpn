FROM kylemanna/openvpn:latest

ARG K8S_VERSION=v1.5.1

ARG GITHUB_TOKEN
ARG REPO=cloudposse/github-pam
ARG FILE=github-pam_linux_386
ARG VERSION=0.10

ARG PAM_SCRIPT_VERSION=1.1.8-1

ADD rootfs /

ADD https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

ADD https://raw.githubusercontent.com/cloudposse/build-harness/master/scripts/gh-dl-release /bin/gh-dl-release
RUN chmod +x /bin/gh-dl-release

RUN set -ex \
      && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
      && apk update \
      && apk add \
        linux-pam \
        ca-certificates

RUN if [ ! -z $GITHUB_TOKEN ]; then \
      set -ex \
      && apk update \
      && apk add --no-cache --virtual .build-deps
        curl \
        jq \
      && gh-dl-release $VERSION github-pam-plugin \
      && chmod +x github-pam-plugin \
      && mv github-pam-plugin /bin/ \
      && apk del .build-deps; \
    else \
      echo '`GITHUB_TOKEN` required for fetching github-pam-plugin'; \
      exit 1; \
    fi

RUN set -ex \
      && apk update \
      && apk add --no-cache --virtual .build-deps \
          curl \
          libtool \
          autoconf \
          automake \
          build-base \
          linux-pam-dev \
      && cd /tmp \
      && curl --max-redirs 10 https://codeload.github.com/jeroennijhof/pam_script/zip/$PAM_SCRIPT_VERSION > pam_script.zip \
      && unzip pam_script.zip \
      && cd pam_script-$PAM_SCRIPT_VERSION \
      && libtoolize --force \
      && aclocal \
      && autoheader \
      && automake --force-missing --add-missing \
      && autoconf \
      && ./configure \
      && make \
      && make install \
      && mv  /usr/local/lib/pam_script.so /lib/security/pam_script.so \
      && cd ../ \
      && rm -rf pam_script-$PAM_SCRIPT_VERSION \
      && rm -rf pam_script.zip \
      && apk del .build-deps;