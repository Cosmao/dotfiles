## Cosmos dotfiles

Dotfiles managed with [stow](https://www.gnu.org/software/stow/).

### Programs

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

**Restow after clone:**
```
stow -v -R .
```

**Rebuild Python packages after update:**
```
paru -S $(pacman -Qoq /usr/lib/python3.XX) --rebuild
```
