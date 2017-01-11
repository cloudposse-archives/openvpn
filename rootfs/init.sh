#!/usr/bin/env bash

sed -i "s|{{GITHUB_PAM_TEAM}}|$GITHUB_PAM_TEAM|g" /etc/pam.d/openvpn

ovpn_run