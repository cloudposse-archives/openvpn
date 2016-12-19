FROM kylemanna/openvpn

RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.3.6/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/

COPY verify /bin/verify
COPY save_secrets /bin/save_secrets
COPY enable_password_auth /bin/enable_password_auth