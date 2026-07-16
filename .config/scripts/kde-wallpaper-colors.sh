#!/bin/bash
# -----------------------------------------------------
# Generate a matugen colour profile from the current KDE
# Plasma wallpaper (terminal + neovim only, no KDE theming).
#
# Usage:
#   kde-wallpaper-colors.sh            # use the active Plasma wallpaper
#   kde-wallpaper-colors.sh <image>    # use a specific image file
# -----------------------------------------------------
set -euo pipefail

CONFIG="$HOME/.config/matugen/config-kde.toml"
APPLETSRC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

command -v matugen >/dev/null 2>&1 || { echo "Requires matugen, aborting." >&2; exit 1; }

# -----------------------------------------------------
# Resolve a wallpaper entry to an actual image file.
# Plasma stores either a direct image path or a wallpaper
# *package* directory (image lives in contents/images/).
# -----------------------------------------------------
resolveImage() {
    local entry="${1#file://}"

    if [[ -f "$entry" ]]; then
        echo "$entry"
        return 0
    fi

    if [[ -d "$entry" ]]; then
        # Pick the largest image in the package (best resolution).
        local img
        img=$(find "$entry/contents/images" "$entry/contents/images_dark" \
                -maxdepth 1 -type f \
                \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
                   -o -iname '*.webp' -o -iname '*.jxl' \) \
                -printf '%s\t%p\n' 2>/dev/null | sort -n | tail -1 | cut -f2-)
        [[ -n "$img" ]] && { echo "$img"; return 0; }
    fi

    return 1
}

getPlasmaWallpaper() {
    [[ -f "$APPLETSRC" ]] || return 1
    # Each Image= line is a candidate; return the first that resolves.
    local entry img
    while IFS= read -r entry; do
        entry="${entry#Image=}"
        [[ -z "$entry" ]] && continue
        if img=$(resolveImage "$entry"); then
            echo "$img"
            return 0
        fi
    done < <(grep -h '^Image=' "$APPLETSRC" | sort -u)
    return 1
}

# -----------------------------------------------------
# Select source image
# -----------------------------------------------------
if [[ $# -ge 1 ]]; then
    FILE=$(resolveImage "$1") || { echo "Could not resolve image: $1" >&2; exit 1; }
else
    FILE=$(getPlasmaWallpaper) || { echo "Could not determine the KDE wallpaper." >&2; exit 1; }
fi

echo "Generating colours from: $FILE"
# --prefer keeps it deterministic (matugen otherwise prompts when an image
# yields several candidate source colours, which breaks non-interactive runs).
matugen image --continue-on-error --prefer saturation -c "$CONFIG" "$FILE"
echo "Done. Restart neovim (or :colorscheme matugen) to pick up the palette."
