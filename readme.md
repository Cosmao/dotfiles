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

### Notes

**Restow after clone:**
```
stow -v -R .
```

**Rebuild Python packages after update:**
```
paru -S $(pacman -Qoq /usr/lib/python3.XX) --rebuild
```
