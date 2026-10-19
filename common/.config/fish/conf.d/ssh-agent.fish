# -----------------------------------------------------
# SSH-agent
# -----------------------------------------------------
# One agent per user (keys expire after 9h), shared with every shell via
# $XDG_RUNTIME_DIR/ssh-agent.env. Written in sh syntax so zsh's
# zshrc/40-autostart reads the same file.
set -l envfile $XDG_RUNTIME_DIR/ssh-agent.env
if not pgrep -u $USER ssh-agent >/dev/null
    ssh-agent -s -t 9h >$envfile
end
if not test -S "$SSH_AUTH_SOCK"; and test -f $envfile
    while read -l line
        if set -l kv (string match -rg '^(SSH_\w+)=([^;]*);' -- $line)
            set -gx $kv[1] $kv[2]
        end
    end <$envfile
end
