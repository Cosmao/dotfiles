## Cosmos dotfiles

Dotfiles managed with [stow](https://www.gnu.org/software/stow/), shared between a laptop (Arch + Hyprland) and a desktop (CachyOS + KDE).

### Layout

| Path | Contents |
|---|---|
| `common/` | Shared by every host: nvim, kitty, fish, zsh, ssh, git, scripts… |
| `hosts/laptop/` | Hyprland, waybar, rofi, wlogout, lf, matugen config |
| `hosts/desktop/` | KDE bits: baloo, default terminal |
| `system/common/`, `system/<host>/` | Files for `/` (udev rules, ly, system units), copied with sudo |

```sh
./install.sh desktop   # first run on a machine: link common/ + hosts/desktop/
./install.sh           # later runs reuse the host saved in .host
./install.sh -n        # dry run
./install.sh -s        # also copy system/ files into / (sudo)
```

Every file lives in exactly one place — stow refuses if `common/` and a host ship the same path. When a shared config needs per-host values, the shared file includes a host file:

| Config | Host file |
|---|---|
| kitty | `.config/kitty/host.conf` (theme, font size) |
| zsh | `.config/zshrc/50-host` |
| fish | `.config/fish/conf.d/host.fish` |

A config that can't include anything gets a full copy in each `hosts/<host>/`.

`install.sh` records the links it made in `.links` (gitignored). The next run removes any of them the host no longer ships, whether the file was moved or deleted in the repo or belongs to another host.

If an app replaced one of the symlinks with a real file, `install.sh` asks whether to revert it to the repo version (the local edits are saved to `.adopted-<time>.patch`) or keep the edits as uncommitted changes.

Secrets go in `~/.config/zshrc/10-secrets` as a plain file in `$HOME`, not in the repo. `.zshrc` sources everything in that directory; fish (`conf.d/secrets.fish`) reads the `export NAME=value` lines from the same file.

On a machine still linked by the old single-package stow (folded directory symlinks), run `./unfold.sh` once first.

### Programs (laptop)

| Program | Role |
|---|---|
| [Hyprland](https://hyprland.org/) | Wayland compositor |
| [Ly](https://github.com/fairyglade/ly) | Display manager |
| [Hyprpaper](https://github.com/hyprwm/hyprpaper) | Wallpaper |
| [Hypridle](https://github.com/hyprwm/hypridle) / [Hyprlock](https://github.com/hyprwm/hyprlock) | Idle / lock screen |
| [waybar](https://github.com/Alexays/Waybar) | Status bar |
| [wlogout](https://github.com/ArtsyMacaw/wlogout) | Logout menu |
| [rofi](https://github.com/davatorium/rofi) | App launcher / clipboard |
| [dunst](https://dunst-project.org/) | Notifications |
| [kitty](https://sw.kovidgoyal.net/kitty/) | Terminal |
| [neovim](https://neovim.io/) | Editor |
| [lf](https://github.com/gokcehan/lf) | File manager |
| [zsh](https://www.zsh.org/) + [oh-my-posh](https://ohmyposh.dev/) | Shell |
| [matugen](https://github.com/InioX/matugen) | Wallpaper-based theming |
| [grimblast](https://github.com/hyprwm/contrib) + [satty](https://github.com/gabm/Satty) | Screenshots |
| [cliphist](https://github.com/sentriz/cliphist) | Clipboard manager |
| [wlsunset](https://sr.ht/~kennylevinsen/wlsunset/) | Blue light filter |

### Theming

Colors are generated from the current wallpaper using **matugen** and applied to hyprland, kitty, waybar, wlogout, rofi, and neovim. Run `wallpaper.sh` or `wallpaper.sh -r` for a random pick.

Neovim themes are switchable at runtime with `<leader>ft`. Available themes: tokyonight-night, tokyonight-transparent, catppuccin, rose-pine, matugen (base16).

### Keybindings

| Binding | Action |
|---|---|
| `SUPER+SHIFT+S` | Screenshot region → clipboard |
| `SUPER+SHIFT+D` | Screenshot region → satty (annotate) |
| `SUPER+V` | Clipboard history (cliphist) |
| `CTRL+META+Q` | Lock screen |

### TODO

- [ ] Secure boot setup
- [ ] Hibernate support
- [ ] Spotify install
- [ ] Fix missing hardware icon in waybar (U+E473 — needs correct nerd font package)
- [ ] Printer setup (cups + avahi)

### Neovim project config

Per-project settings live in a `.nvim.lua` file in the project root (loaded via `exrc`).

Projects are declared as a table — `<leader>or` shows a project picker, then a type-appropriate action menu.

```lua
vim.g.projects = {
  { type = 'cargo', root = '.', target = 'thumbv7em-none-eabihf', chip = 'STM32F411CEUx' },
  { type = 'idf', root = 'esp-component' },
}
```

**Project entry fields:**

| Field | Type | Description |
|---|---|---|
| `type` | `'cargo'` \| `'idf'` | Project type |
| `name` | string | Display name in pickers. Defaults to `root` basename, then type name. |
| `root` | string | Relative path to project dir (default `.`) |
| `target` | string | Cargo: target triple e.g. `thumbv7em-none-eabihf`. Omit for native. |
| `chip` | string | Cargo: probe-rs chip e.g. `STM32F411CEUx`. Enables probe-rs actions and DAP. |
| `binary` | string | Cargo: override ELF path. Defaults to `<root>/target/<target>/debug/<dirname>`. |

**ESP-IDF** (`type = 'idf'`): `root` is a relative path to the ESP-IDF project directory (defaults to `.`). The path is resolved against cwd — it must contain a `CMakeLists.txt`. Requires `export.sh` sourced separately before running tasks.

**Examples:**

STM32 black pill:
```lua
vim.g.projects = {
  { type = 'cargo', root = '.', target = 'thumbv7em-none-eabihf', chip = 'STM32F411CEUx' },
}
```

Monorepo with Rust firmware and ESP-IDF component:
```lua
vim.g.projects = {
  { type = 'cargo', root = 'firmware', target = 'thumbv7em-none-eabihf', chip = 'STM32F411CEUx' },
  { type = 'idf', root = 'esp-component' },
}
```

DAP (`<leader>dc`): start `probe-rs dap-server` first via `<leader>or` → Project → probe-rs: DAP server.

### Notes

**Restow after clone or pull:**
```
./install.sh <host>   # or restow.sh, which runs it from ~/dotfiles
```

**Restart rclone after suspend** (needs `./install.sh -s` first):
```
sudo systemctl enable rclone-resume@$USER.service
```

**Rebuild Python packages after update:**
```
paru -S $(pacman -Qoq /usr/lib/python3.XX) --rebuild
```
