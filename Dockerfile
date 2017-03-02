FROM kylemanna/openvpn:latest

ARG K8S_VERSION=v1.5.1

ADD https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

ARG GITHUB_TOKEN
ARG PAM_SCRIPT_VERSION=1.1.8-1
ARG S6_OVERLAY_VER=1.17.2.0

# Install s6-overlay
RUN set -ex \
    && apk update \
    && apk add --no-cache --virtual .build-deps \
          curl \
    && curl https://s3.amazonaws.com/wodby-releases/s6-overlay/v${S6_OVERLAY_VER}/s6-overlay-amd64.tar.gz | tar xz -C / \
    && apk del .build-deps;

ADD rootfs /

ADD https://raw.githubusercontent.com/cloudposse/build-harness/master/templates/Makefile.build-harness Makefile

RUN if [ ! -z $GITHUB_TOKEN ]; then \
      set -ex \
      && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
      && apk update \
      && apk add --no-cache --virtual .build-deps \
          curl \
          jq \
          linux-pam \
          pamtester \
          make \
          git \
      && make  \
      && REPO=cloudposse/github-pam \
          VERSION=0.10 \
          FILE=github-pam_linux_386 \
          OUTPUT=github-pam-plugin \
          make github:download-release  \
      && chmod +x github-pam-plugin \
      && mv github-pam-plugin /bin/ \
      && apk add ca-certificates \
      && apk del .build-deps; \
    else \
      echo '`GITHUB_TOKEN` required for fetching github-pam-plugin'; \
      exit 1; \
    fi

RUN if [ ! -z $GITHUB_TOKEN ]; then \
      set -ex \
      && apk update \
      && apk add --no-cache --virtual .build-deps \
          curl \
          jq \
          git \
          make \
      && make \
      && REPO=cloudposse/openvpn-api \
          VERSION=0.1 \
          FILE=openvpn-api_linux_386 \
          OUTPUT=openvpn-api \
          make github:download-release \
      && chmod +x openvpn-api \
      && mv openvpn-api /bin/ \
      && apk del .build-deps; \
    else \
      echo '`GITHUB_TOKEN` required for fetching openvpn-api'; \
      exit 1; \
    fi

RUN set -ex \
      && apk update \
      && apk add linux-pam \
      && apk add --no-cache --virtual .build-deps \
          curl \
          libtool \
          autoconf \
          automake \
          build-base \
          linux-pam-dev \
          pamtester \
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


ENTRYPOINT ["/init"]