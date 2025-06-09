#!/bin/bash
set -euo pipefail
CURL_RESPONSE=""
LATEST_VERSION=""
TARBALL_URL=""
TARBALL_NAME=""
SHA512_URL=""
SHA512_NAME=""
DIR_NAME=""

for tool in jq rg sha512sum curl tar basename realpath; do
    command -v $tool >/dev/null 2>&1 || { echo >&2 "$tool is required but not installed."; exit 1; }
done

echo "Setting up temporary working directory"
WORKDIR="$(mktemp -d)"
if [[ ! -d "$WORKDIR" || "$WORKDIR" != /tmp/* ]]; then
    echo "Failed to create a safe temporary directory."
    exit 1
fi

trap '[[ -d "$WORKDIR" && "$WORKDIR" == /tmp/* ]] && rm -rf -- "$WORKDIR"' EXIT
cd "$WORKDIR"

echo "Getting latest version"
CURL_RESPONSE=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest)
LATEST_VERSION=$(echo "$CURL_RESPONSE" | jq -r ."tag_name")
ASSETS_LENGTH=$(echo "$CURL_RESPONSE" | jq -r ."assets | length")

for ((i = 0 ; i < $ASSETS_LENGTH ; i++)); do
   ASSET_NAME=$(echo "$CURL_RESPONSE" | jq -r ."assets[$i].name")
   if echo "$ASSET_NAME" | rg -q ".tar.gz" ; then
      TARBALL_URL=$(echo "$CURL_RESPONSE" | jq -r ."assets[$i].browser_download_url")
      echo "Found tarball"
   fi
   if echo "$ASSET_NAME" | rg -q ".sha512sum" ; then
      SHA512_URL=$(echo "$CURL_RESPONSE" | jq -r ."assets[$i].browser_download_url")
      echo "Found SHA512"
   fi
done

if [ -z "$TARBALL_URL" ] || [ -z "$SHA512_URL" ]; then
   echo "Could not find URLs"
   exit 1
fi

TARBALL_NAME=$(basename "$TARBALL_URL")
SHA512_NAME=$(basename "$SHA512_URL")
DIR_NAME=${TARBALL_NAME%.tar.gz}

DIR_PATH="$HOME/.steam/steam/compatibilitytools.d/$DIR_NAME"
STEAM_PATH="$(realpath "$HOME/.steam/steam/compatibilitytools.d")"
TARGET_PATH="$(realpath "$DIR_PATH" 2>/dev/null)"

if [ -d "$DIR_PATH" ]; then
   while true; do
     read -rp "Version $DIR_NAME already installed, reinstall? (y/n) " yn
     case $yn in
       [yY] )
         if [[ "$TARGET_PATH" == "$STEAM_PATH/"* ]]; then
             rm -rf -- "$TARGET_PATH"
         else
             echo "Invalid directory path. Aborting."
             exit 1
         fi
         break;;
       [nN] ) exit 0; break;;
     esac
   done
fi

echo "Downloading tarball: $TARBALL_NAME"
curl -# -L "$TARBALL_URL" -o "$TARBALL_NAME" --progress-bar

echo "Downloading sha512: $SHA512_NAME"
curl -# -L "$SHA512_URL" -o "$SHA512_NAME" --progress-bar

echo "Verifying sha512"
sha512sum -c "$SHA512_NAME"

mkdir -p "$STEAM_PATH"

echo "Extracting $TARBALL_NAME to Steam directory"
tar -xf "$TARBALL_NAME" -C "$STEAM_PATH"

echo "$DIR_NAME installed successfully!"

exit 0
