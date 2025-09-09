#!/bin/bash
set -euo pipefail

declare -A TARBALLS
declare -A SHA512
declare -A INSTALLED

RELEASES_URL="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases"
#STEAM_PATH="$(realpath "$HOME/.steam/steam/compatibilitytools.d")"

for tool in jq rg sha512sum curl tar basename realpath; do
    command -v $tool >/dev/null 2>&1 || { echo >&2 "$tool is required but not installed."; exit 1; }
done

echo "Setting up temporary working directory"
WORKDIR="$(mktemp -d)"
if [[ ! -d "$WORKDIR" || "$WORKDIR" != /tmp/* ]]; then
    echo "Failed to create a safe temporary directory."
    exit 1
fi
cd "$WORKDIR"

trap '[[ -d "$WORKDIR" && "$WORKDIR" == /tmp/* ]] && rm -rf -- "$WORKDIR"' EXIT

function get_urls(){
   echo "Getting versions"
   local CURL_URL="$1"
   local CURL_RESPONSE=$(curl -s $CURL_URL)
   local NUM_RELEASES=$(echo "$CURL_RESPONSE" | jq -r "length")
   echo $NUM_RELEASES

   for ((num = 0; num < $NUM_RELEASES ; num++)); do
      local TARBALL_URL=""
      local SHA512_URL=""
      local VERSION=$(echo "$CURL_RESPONSE" | jq -r ."[$num].tag_name")
      local ASSETS_LENGTH=$(echo "$CURL_RESPONSE" | jq -r ."[$num].assets | length")
      for ((i = 0 ; i < $ASSETS_LENGTH ; i++)); do
         local ASSET_NAME=$(echo "$CURL_RESPONSE" | jq -r ."[$num].assets[$i].name")
         if echo "$ASSET_NAME" | rg -q ".tar.gz" ; then
            TARBALL_URL=$(echo "$CURL_RESPONSE" | jq -r ."[$num].assets[$i].browser_download_url")
         fi
         if echo "$ASSET_NAME" | rg -q ".sha512sum" ; then
            SHA512_URL=$(echo "$CURL_RESPONSE" | jq -r ."[$num].assets[$i].browser_download_url")
         fi
      done

      if [ -z "$TARBALL_URL" ] || [ -z "$SHA512_URL" ]; then
         echo "Could not find URLs"
         continue
      else
         echo "$VERSION found"
         TARBALLS["$VERSION"]="$TARBALL_URL"
         SHA512["$VERSION"]="$SHA512_URL"
         local TARBALL_NAME=$(basename "$TARBALL_URL")
         local DIR_NAME=${TARBALL_NAME%.tar.gz}
         if [ -d "$STEAM_PATH/$DIR_NAME" ]; then
            INSTALLED["$VERSION"]=1
         else
            INSTALLED["$VERSION"]=0
         fi
      fi
   done
}

   #local TARBALL_NAME=$(basename "$TARBALL_URL")
   #local SHA512_NAME=$(basename "$SHA512_URL")
   #local DIR_NAME=${TARBALL_NAME%.tar.gz}

function download(){
   echo "Downloading tarball: $TARBALL_NAME"
   curl -# -L "$TARBALL_URL" -o "$TARBALL_NAME" --progress-bar

   echo "Downloading sha512: $SHA512_NAME"
   curl -# -L "$SHA512_URL" -o "$SHA512_NAME" --progress-bar

   echo "Verifying sha512"
   sha512sum -c "$SHA512_NAME"

   echo "Extracting $TARBALL_NAME to Steam directory"
   tar -xf "$TARBALL_NAME" -C "$STEAM_PATH"

   echo "$DIR_NAME installed successfully!"
}

function check_if_installed(){
   if [ -d "$STEAM_PATH/$DIR_NAME" ]; then
      TARGET_PATH="$(realpath "$STEAM_PATH/$DIR_NAME" 2>/dev/null)"
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
   else
      while true; do
         read -rp "Version $DIR_NAME not installed, install now? (y/n) " yn
         case $yn in
            [yY] )
               echo "Starting downloads."
               break;;
            [nN] ) 
               exit 0; 
               break;;
         esac
      done
   fi
}

get_urls "$RELEASES_URL"
check_if_installed
download

exit 0
