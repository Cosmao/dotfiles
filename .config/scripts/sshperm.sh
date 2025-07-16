#!/bin/bash 

chmod 700 ~/.ssh
chmod 700 ~/.ssh/id_ed25519/

find ~/.ssh/id_ed25519/ -type f ! -name "*.pub" -exec chmod 600 {} \;

find ~/.ssh/id_ed25519/ -type f -name "*.pub" -exec chmod 644 {} \;

echo "Permissions applied"
