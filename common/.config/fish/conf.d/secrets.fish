# -----------------------------------------------------
# Secrets
# -----------------------------------------------------
# The same ~/.config/zshrc/10-secrets zsh sources: a plain file in $HOME,
# never in the repo. Only `export NAME=value` lines are read, with one
# pair of matching quotes around the value stripped; nothing is expanded.
set -l secrets ~/.config/zshrc/10-secrets
if test -f $secrets
    for line in (command cat $secrets)
        set -l kv (string match -rg '^\s*export\s+([A-Za-z_]\w*)=(.*)$' -- $line)
        or continue
        set -gx $kv[1] (string replace -r '^([\'"])(.*)\1$' '$2' -- "$kv[2]")
    end
end
