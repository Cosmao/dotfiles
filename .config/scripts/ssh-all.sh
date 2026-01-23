#!/bin/bash
set -xeu
: "${SSH_AUTH_SOCK?No ssh-agent running}"
shopt -s nullglob

KEY_ROOT="$HOME/.ssh"
ssh-add -l >/dev/null 2>&1 || \
find "$KEY_ROOT" \
	-path "$KEY_ROOT/deprecated/*" -prune -o \
	-type f \
	! -name "*.pub" \
	! -name "known_*" \
	-exec ssh-add {} +
