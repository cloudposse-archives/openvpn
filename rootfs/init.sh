#!/usr/bin/env bash
envsubst < "/cloudposse/templates/pam/openvpn" > "/etc/pam.d/openvpn"
ovpn_run