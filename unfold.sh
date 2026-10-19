#!/usr/bin/env bash
# One-time migration before the first ./stow.sh run on a machine.
#
# Converts stow's "folded" directory symlinks (e.g. ~/.claude ->
# dotfiles/.claude, which makes apps write caches and state into the
# repo) into real directories: every file git does NOT track is moved
# out of the repo into the real directory; tracked files stay in the
# repo and ./stow.sh symlinks them back afterwards.
set -euo pipefail
cd "$(dirname "$0")"
repo=$PWD

unfold() {
    local link=$1 target f
    [ -L "$link" ] || return 0
    target=$(readlink -f "$link") || return 0
    case $target in "$repo"/*) ;; *) return 0 ;; esac
    [ -d "$target" ] || return 0        # per-file symlinks are fine as-is
    echo "unfolding $link"
    rm "$link"
    mkdir -p "$link"
    git -C "$target" ls-files --others . | while IFS= read -r f; do
        mkdir -p "$link/$(dirname "$f")"
        mv "$target/$f" "$link/$f"
    done
    # drop now-empty cache directories left behind in the repo
    find "$target" -mindepth 1 -type d -empty -delete 2>/dev/null || true
}

for link in "$HOME"/.* "$HOME"/.config/*; do
    unfold "$link"
done

echo "done — now run ./stow.sh"
