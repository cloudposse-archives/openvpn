FROM kylemanna/openvpn:latest

ARG K8S_VERSION=v1.5.1

RUN wget https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/

ARG GITHUB_TOKEN
ARG REPO=cloudposse/github-pam
ARG FILE=github-pam_linux_386
ARG VERSION=0.10
ARG PAM_SCRIPT_VERSION=1.1.8-1

ADD rootfs /

RUN curl https://gist.githubusercontent.com/goruha/dc4c5eca4d8322b19ff718d5e1510723/raw/4709cc7c794e1945aa84a3ed08d5a04de14fbda6/gh-dl-release \
    > /bin/gh-dl-release \
    && chmod +x /bin/gh-dl-release

RUN if [ ! -z $GITHUB_TOKEN ]; then \
      set -ex \
      && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
      && apk update \
      && apk add --no-cache --virtual .build-deps \
		      curl \
		      jq \
		      linux-pam \
		      pamtester \
		  && gh-dl-release $VERSION github-pam-plugin \
      && chmod +x github-pam-plugin \
      && mv github-pam-plugin /bin/ \
      && apk add ca-certificates \
      && apk del .build-deps; \
    else \
      echo '`GITHUB_TOKEN` required for fetching github-pam-plugin'; \
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