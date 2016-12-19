FROM kylemanna/openvpn

RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.3.6/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/

ADD verify /bin/
ADD save_secrets /bin/
ADD enable_password_auth /bin/