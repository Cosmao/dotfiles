#!/bin/bash 

chmod 700 ~/.ssh
chmod 700 ~/.ssh/id_ed25519/

# ControlPath socket dir (referenced by .ssh/config); git can't track an
# empty dir or its perms, so create it here.
mkdir -p -m 700 ~/.ssh/sockets

find ~/.ssh/id_ed25519/ -type f ! -name "*.pub" -exec chmod 600 {} \;

find ~/.ssh/id_ed25519/ -type f -name "*.pub" -exec chmod 644 {} \;

echo "Permissions applied"
