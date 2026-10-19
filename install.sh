#!/usr/bin/env bash
# Link the dotfiles into $HOME: common/ plus hosts/<host>/.
#
# Usage: ./install.sh [-n] [-s] [host]
#   host  a directory under hosts/ (laptop, desktop). Remembered in .host,
#         so later runs can leave it out.
#   -n    dry run: show what stow would do, change nothing
#   -s    also copy system/common/ and system/<host>/ into / (sudo)
#
# Every target path must come from exactly one package. If common/ and a
# host both ship the same file, stow refuses with a conflict. Per-host
# variants of a shared config go in a host file that the shared one
# includes (kitty host.conf, zshrc/50-host, fish conf.d/host.fish).
#
# --no-folding : real directories in $HOME, symlinks for files only, so
#                runtime/generated files never land inside this repo.
# --adopt      : a real file already at a target path (an app wrote its
#                own default) is moved into the repo and symlinked; the
#                git restore afterwards puts the repo's version back, so
#                the repo always wins.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
repo=$PWD

usage() {
    echo "usage: $0 [-n] [-s] [host]   hosts: $(ls hosts | tr '\n' ' ')" >&2
    exit 1
}

dry=0 system=0
while getopts ns opt; do
    case $opt in
        n) dry=1 ;;
        s) system=1 ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

host=${1:-$(cat .host 2>/dev/null || true)}
[[ -n $host ]] || usage
[[ -d hosts/$host ]] || { echo "error: no hosts/$host" >&2; usage; }

stow_opts=(--no-folding --target="$HOME")

if ((dry)); then
    stow -n -v "${stow_opts[@]}" --adopt --dir="$repo" --restow common
    stow -n -v "${stow_opts[@]}" --adopt --dir="$repo/hosts" --restow "$host"
    exit 0
fi

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    echo "error: uncommitted changes to tracked files — commit or stash first." >&2
    echo "       (--adopt + git restore would discard them)" >&2
    exit 1
fi

# Drop symlinks into this repo whose target no longer exists (files that
# were moved or deleted in the repo), so they don't linger in $HOME.
prune() {
    local top=$1 link
    [[ -d $HOME/$top && ! -L $HOME/$top ]] || return 0
    find "$HOME/$top" -xdev -xtype l -print0 | while IFS= read -r -d '' link; do
        case $(readlink -m "$link") in
            "$repo"/*) echo "prune: ${link#"$HOME"/}"; rm "$link" ;;
        esac
    done
}
find "$HOME" -maxdepth 1 -xtype l -print0 | while IFS= read -r -d '' link; do
    case $(readlink -m "$link") in "$repo"/*) echo "prune: ${link#"$HOME"/}"; rm "$link" ;; esac
done
for top in $({ ls -A common; ls -A "hosts/$host"; } | sort -u); do
    prune "$top"
done

# Switching hosts: remove the other hosts' links first.
for other in hosts/*/; do
    other=$(basename "$other")
    [[ $other == "$host" ]] && continue
    stow -D "${stow_opts[@]}" --dir="$repo/hosts" "$other" 2>/dev/null || true
done

stow "${stow_opts[@]}" --adopt --dir="$repo" --restow common
stow "${stow_opts[@]}" --adopt --dir="$repo/hosts" --restow "$host"
git restore -- common "hosts/$host"
echo "$host" > .host
echo "stowed common + $host into $HOME (repo versions win)"

if ((system)); then
    for src in system/common system/"$host"; do
        [[ -d $src ]] || continue
        find "$src" -type f | while read -r f; do
            dest=/${f#"$src"/}
            if ! cmp -s "$f" "$dest"; then
                sudo install -Dm644 "$f" "$dest"
                echo "system: $dest"
            fi
        done
    done
    echo "system files in place. If any changed: sudo systemctl daemon-reload,"
    echo "sudo udevadm control --reload, and enable new units as needed."
fi
