#!/bin/bash
# -----------------------------------------------------
# Wallpaper manager
# -----------------------------------------------------

# -----------------------------------------------------
# Program checks
# -----------------------------------------------------
command -v hyprctl >/dev/null 2>&1 || { echo "Requires hyprland, aborting."; exit 1; }
command -v matugen >/dev/null 2>&1 || { echo "Requires matugen, aborting."; exit 1; }
command -v magick >/dev/null 2>&1 || { echo "Requires imagemagick, aborting."; exit 1; }

if [ "$TERM" != "xterm-kitty" ]; then
    echo "Must be run inside kitty for preview to work, aborting."
    exit 1
fi

# -----------------------------------------------------
# Functions
# -----------------------------------------------------
getCurrentWallpaper() {
    awk '/^\s*path\s=\s/ {print $3; exit}' ~/.config/hypr/hyprpaper.conf
}

isSupported() {
    local ext="${1##*.}"
    case "${ext,,}" in
        png|jpg|jpeg|jxl|webp) return 0 ;;
        *) return 1 ;;
    esac
}

setHyprpaper() {
    sed -i "s|^\(\s*path\s*=\s*\).*|\1${1}|" ~/.config/hypr/hyprpaper.conf
    hyprctl hyprpaper wallpaper ",$1" >/dev/null
}


generateBlurred() {
    magick "$1" -blur "50x30" "$WALLPAPERPATH/current_blurred.png"
}

getRandomPicture() {
    local current
    current=$(getCurrentWallpaper)

    local pics=()
    while IFS= read -r -d $'\0' f; do
        pics+=("$f")
    done < <(find "$WALLPAPERPATH" -maxdepth 1 -type f \( \
        -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \
        -o -iname "*.jxl" -o -iname "*.webp" \
    \) ! -name "current_blurred.png" -print0)

    if (( ${#pics[@]} == 0 )); then
        echo "No supported images found in $WALLPAPERPATH" >&2
        exit 1
    fi

    local chosen
    while : ; do
        chosen="${pics[$RANDOM % ${#pics[@]}]}"
        [[ "$chosen" != "$current" ]] && break
    done

    echo "$chosen"
}

# -----------------------------------------------------
# Argument parsing
# -----------------------------------------------------
RANDOM_MODE="false"

while getopts "r" flag; do
    case "${flag}" in
        r) RANDOM_MODE="true" ;;
        ?) echo "Usage: wallpaper.sh [-r] [file]"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# -----------------------------------------------------
# Select wallpaper
# -----------------------------------------------------
if [[ "$RANDOM_MODE" == "true" ]]; then
    FILE=$(getRandomPicture)
else
    FILE="$1"
    if [[ -z "$FILE" ]]; then
        echo "Usage: wallpaper.sh [-r] [file]"
        exit 1
    fi
    if [[ ! -f "$FILE" ]]; then
        echo "File not found: $FILE"
        exit 1
    fi
    if ! isSupported "$FILE"; then
        echo "Unsupported format: ${FILE##*.}"
        exit 1
    fi
fi

CURRENT=$(getCurrentWallpaper)
if [[ "$FILE" == "$CURRENT" ]]; then
    echo "Already using that wallpaper."
    exit 0
fi

# -----------------------------------------------------
# Preview
# -----------------------------------------------------
kitty +icat "$FILE"
echo

read -rp "Use this wallpaper? (y/n) " -n 1
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

matugen image --continue-on-error "$FILE"
setHyprpaper "$FILE"
generateBlurred "$FILE" &
echo "Done."
