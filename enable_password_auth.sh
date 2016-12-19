#!/bin/bash

conf=${OPENVPN:-}/openvpn.conf

echo -e "\n\n# Username and Password authentication." >> "$conf"
echo -e "client-cert-not-required" >> "$conf"
echo "auth-user-pass-verify /etc/openvpn/verify.sh via-file" >> "$conf"
echo "username-as-common-name" >> "$conf"
echo "tmp-dir /etc/openvpn/tmp" >> "$conf"