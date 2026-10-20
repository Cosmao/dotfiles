#!/usr/bin/env bash
# Link the dotfiles into $HOME: common/ plus hosts/<host>/.
#
# Usage: ./install.sh [-n] [-s] [host]
#   host  a directory under hosts/ (laptop, desktop). Remembered in .host,
#         so later runs can leave it out.
#   -n    dry run: show what would be pruned, linked and (with -s) copied.
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
#                own default) is moved into the repo and symlinked. If that
#                changed a tracked file you choose: revert to the repo
#                version (local edits saved to .adopted-<time>.patch) or
#                keep the edits as uncommitted changes to commit.
#
# .links lists every $HOME path linked on the last run. Links into this
# repo that the current host no longer wants (file moved or deleted in the
# repo, or belonging to another host) are pruned before stowing.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
repo=$PWD
manifest=$repo/.links

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
((dry)) && stow_opts+=(-n -v)

if ((!dry)) && [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    echo "error: uncommitted changes to tracked files — commit or stash first." >&2
    echo "       (--adopt + git restore would discard them)" >&2
    exit 1
fi

# Every path this host links, mapped to the repo file it should point at.
declare -A want
for pkg in common "hosts/$host"; do
    while IFS= read -r -d '' f; do
        f=${f#./}
        want[$f]=$repo/$pkg/$f
    done < <(cd "$pkg" && find . \( -type f -o -type l \) -print0)
done

# Links to check for pruning: the last run's manifest. Without one (first
# run, or a machine still on the old single-package layout that also
# stowed etc/ into $HOME), every symlink one level deep in each directory
# that ever held a file in this repo's history, package prefix stripped.
prune_candidates() {
    if [[ -f $manifest ]]; then
        cat "$manifest"
        return
    fi
    local d dir link
    git log --format= --name-only --no-renames HEAD |
        sed -E 's#^(common|hosts/[^/]+|system/[^/]+)/##; /\//!s#.*##; s#/[^/]*$##' |
        sort -u |
        while IFS= read -r d; do
            dir=$HOME${d:+/$d}
            [[ -d $dir && ! -L $dir ]] || continue
            find "$dir" -mindepth 1 -maxdepth 1 -type l -print0 2>/dev/null |
                while IFS= read -r -d '' link; do
                    echo "${link#"$HOME"/}"
                done
        done
}

declare -A pruned
while IFS= read -r rel; do
    link=$HOME/$rel
    [[ -L $link ]] || continue
    dest=$(readlink -m "$link")
    [[ $dest == "$repo"/* && $dest != "${want[$rel]:-}" ]] || continue
    echo "prune: $rel"
    pruned[$rel]=1
    ((dry)) || rm "$link"
done < <(prune_candidates)

# stow_pkg <stow dir> <package>
stow_pkg() {
    if ((!dry)); then
        stow "${stow_opts[@]}" --adopt --dir="$1" --restow "$2"
        return
    fi
    # Dry run: nothing was pruned, so stow sees the prune: links above as
    # conflicts (or plans to unlink them). Show those as the links they
    # become after the prune; any other conflict is real. --restow also
    # plans an unlink + link for every link that is already correct; drop
    # those so only changes are shown.
    local out line path plan=() conflicts=()
    out=$(stow "${stow_opts[@]}" --adopt --dir="$1" --restow "$2" 2>&1) || true
    while IFS= read -r line; do
        case $line in
            '  * '*)
                path=${line##*: }
                path=${path%% => *}
                if [[ -n ${pruned[$path]:-} ]]; then
                    plan+=("LINK: $path (after prune)")
                else
                    conflicts+=("$line")
                fi
                ;;
            'UNLINK: '* | 'LINK: '*)
                path=${line#*: }
                path=${path%% => *}
                [[ $line == UNLINK* && -n ${pruned[$path]:-} ]] && continue
                [[ -L $HOME/$path && $(readlink -m "$HOME/$path") == "${want[$path]:-}" ]] && continue
                plan+=("$line")
                ;;
            'WARNING! stowing'* | 'All operations aborted.' | 'WARNING: in simulation mode'*) ;;
            ?*) plan+=("$line") ;;
        esac
    done <<<"$out"
    ((${#plan[@]})) && printf '%s\n' "${plan[@]}"
    if ((${#conflicts[@]})); then
        echo "conflicts stowing $2 (a real run would abort):"
        printf '%s\n' "${conflicts[@]}"
    fi
}

stow_pkg "$repo" common
stow_pkg "$repo/hosts" "$host"

if ((!dry)); then
    for rel in "${!want[@]}"; do
        if [[ -L $HOME/$rel && $(readlink -m "$HOME/$rel") == "${want[$rel]}" ]]; then
            echo "$rel"
        fi
    done | sort >"$manifest"

    # Files adopted from $HOME that differed from the repo: usually an app
    # replaced its symlink with a real file (e.g. KDE saving a setting).
    if ! git diff --quiet -- common "hosts/$host"; then
        echo "adopted from \$HOME, differs from the repo:" >&2
        git --no-pager diff --stat -- common "hosts/$host" >&2
        answer=r
        while [[ -t 0 ]]; do
            read -rp "[r]evert to repo version, [k]eep local edits, show [d]iff? [r] " answer || answer=r
            answer=${answer:-r}
            case $answer in
                d*) git diff -- common "hosts/$host" ;;
                r* | k*) break ;;
            esac
        done
        if [[ $answer == k* ]]; then
            echo "kept: commit (or git restore) them before the next run." >&2
        else
            patch=.adopted-$(date +%Y%m%d-%H%M%S).patch
            git diff -- common "hosts/$host" >"$patch"
            git restore -- common "hosts/$host"
            echo "reverted (local edits saved to $patch)" >&2
        fi
    fi
    echo "$host" >.host
    echo "stowed common + $host into $HOME"
fi

if ((system)); then
    for src in system/common system/"$host"; do
        [[ -d $src ]] || continue
        find "$src" -type f | while read -r f; do
            dest=/${f#"$src"/}
            cmp -s "$f" "$dest" && continue
            if ((dry)); then
                echo "system: would install $dest"
            else
                sudo install -Dm644 "$f" "$dest"
                echo "system: $dest"
            fi
        done
    done
    ((dry)) || {
        echo "system files in place. If any changed: sudo systemctl daemon-reload,"
        echo "sudo udevadm control --reload, and enable new units as needed."
    }
fi
