#!/bin/bash
PACKAGE_NAME="$1"
if [ -z "$PACKAGE_NAME" ]; then
   echo "Need package name"
   exit 1
fi

pacman -Qi | awk -v RS= "/^Name\s+:\s+$PACKAGE_NAME\n/"
