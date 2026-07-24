# Config System

All dotfiles are managed via GNU Stow in `~/dotfiles/`. `~/.config/X` is a symlink to `../dotfiles/.config/X`. Edit files inside `~/dotfiles/`, not the symlinks.

## Stow-Managed Configs (symlinked from `~/dotfiles/`)

| Path in `~/dotfiles/` | Symlinked to |
|---|---|
| `.bashrc`, `.bash_profile`, `.bash_logout` | `~/` |
| `.local/bin/` (223 scripts) | `~/.local/bin/` |
| `.config/hypr/` | Hyprland WM: `hyprland.conf`, `hyprlock.conf`, `hypridle.conf`, `hyprsunset.conf`, `xdph.conf`, `apps.conf`, `hyprbole-managed.conf`, keybinds, autostart, envs, monitors, input, looknfeel, windows |
| `.config/waybar/` | Top bar; `config.jsonc` active, `theme.css` for colors, `indicators/` for status scripts |
| `.config/walker/` | App launcher; `config.toml` with providers/keybinds |
| `.config/swayosd/` | OSD overlays; `config.toml` + `style.css` (imports `../themes/current/swayosd.css`) |
| `.config/elephant/` | App launcher; `elephant.toml`, `calc.toml`, `symbols.toml`, `desktopapplications.toml`, `providers/menus.so` |
| `.config/ghostty/` | Terminal; `config` + `screensaver` subdir |
| `.config/fish/` | Shell; `config.fish` sets PATH, aliases, keybindings; `conf.d/`, `functions/`, `completions/`, `themes/`, `fish_plugins`, `fish_variables` |
| `.config/nvim/` | Neovim config (LazyVim-based) |
| `.config/tmux/` | Tmux config |
| `.config/btop/` | System monitor; `btop.conf` + `themes/current.theme` |
| `.config/fastfetch/` | System fetch; `config.jsonc` + ascii art files |
| `.config/yazi/` | File manager; `yazi.toml` |
| `.config/starship.toml` | Prompt |
| `.config/spicetify/` | Spotify theme; `config-xpui.ini`, `CustomApps/`, `Extensions/`, `Themes/` |
| `.config/vesktop/` | Discord client; `settings.json`, `themes/` |
| `.config/hyprland-preview-share-picker/` | Screenshot region picker; `config.yaml` |

## Theme System (`~/.config/themes/`)

The theme system uses `~/.config/themes/` as its root (runtime data directory, not stowed).

| Directory | Purpose |
|---|---|
| `~/.config/themes/<name>/` | Installed theme packs (one subdir per theme) |
| `~/.config/themes/current/` | Active theme (symlinked configs point here) |
| `~/.config/themes/current/backgrounds/` | Wallpaper images for the active theme |
| `~/.config/themes/current/background` | Symlink to the active wallpaper image |
| `~/.config/themes/current/theme.name` | Plain text file with the current theme name |
| `~/.config/themes/backgrounds/<name>/` | User-custom backgrounds per theme |
| `~/.config/themes/hooks/` | Hook scripts for theme-set events |
| `~/.config/themes/templates/` | Optional template files for dynamic config generation |

The `theme-set <name>` command copies the theme from `~/.config/themes/<name>/` to `~/.config/themes/current/`, runs templates, and restarts affected services.

### Referenced by

| Consumer | Path reference |
|---|---|
| `hypr/hyprland.conf` | `source = ~/.config/themes/current/hyprland.conf` |
| `hypr/hyprlock.conf` | `source = ~/.config/themes/current/hyprlock.conf` |
| `hypr/hyprlock.conf` | `path = ~/.config/themes/current/backgrounds/BG1_2.png` |
| `hypr/autostart.conf` | `swaybg -i ~/.config/themes/current/background` |
| `swayosd/style.css` | `@import "../themes/current/swayosd.css"` |
| `waybar/style.css` | `@import "~/.config/themes/current/waybar.css"` |

### Contents of a theme directory

| File | Purpose |
|---|---|
| `backgrounds/` | Wallpaper images |
| `hyprland.conf` | Theme-specific Hyprland vars (active border color, animations) |
| `hyprlock.conf` | Lock screen colors (variables like `$color`, `$font_color`) |
| `mako.ini` | Notification daemon theme |
| `walker.css` | App launcher CSS |
| `waybar.css` | Top bar theme colors (`@background`, `@foreground`) |
| `swayosd.css` | OSD theme |
| `colors.toml` | Base16 color palette (accent, foreground, background, color0-15) |
| `colors.fish` | Fish shell color vars |
| `gtk.css` | GTK theme overrides |
| `btop.theme` | System monitor theme |
| `cava_theme` | Audio visualizer theme |
| `neovim.lua` | Neovim theme colors |
| `vscode.json` | VS Code theme colors |
| `zed.json` / `aether.zed.json` | Zed editor themes |

To change wallpaper: edit `BG1_2.png` and update `hyprlock.conf` + `autostart.conf` if you want a different filename.

## Non-Stow Configs

These live directly in `~/.config/` (not symlinked to dotfiles):

- `systemd/`, `uwsm/`, `fontconfig/`, `gtk-3.0/`, `gtk-4.0/`, `fcitx5/`, `kitty/`, `cava/`, `nautilus/`, `dconf/`, `pulse/`, `git/`, `go/`, `zed/`, `zen/`, `obsidian/`, `themes/` (runtime theme data), various app configs

## Important Paths

- `~/dotfiles/` — dotfiles repo (stow root)
- `~/.config/themes/` — runtime theme data directory (not stowed)
- `~/.config/themes/current/` — active theme files
- `~/.config/themes/current/backgrounds/` — wallpapers
- `~/.config/themes/hooks/` — theme-set hook scripts
- `~/.config/themes/templates/` — optional template files for dynamic config generation
- `~/.local/bin/` — all CLI scripts

## Commands

- `stow -d ~/dotfiles -t ~ --restow .` — re-stow all dotfiles after adding new files
- `stow -D -d ~/dotfiles -t ~ .` — un-stow everything
- `./bootstrap.sh` — full setup from fresh Arch install (packages + stow + scripts)
- `./install.sh` — install/update packages from pkglist.txt + aurlist.txt
- `./gitssh.sh` — generate SSH key and configure git commit signing

## Theme Commands

- `theme-set <name>` — apply a theme
- `theme-current` — show current theme name
- `theme-list` — list available themes
- `theme-install <git-url> [name]` — install a theme from git
- `theme-remove <name>` — remove a theme
- `theme-update` — update all themes from git
- `theme-refresh` — reapply current theme
- `theme-bg-set <path>` — set background image
- `theme-bg-next` — cycle to next background
- `theme-bg-install <path>` — install a background
- `hook <name>` — run hook scripts

## Fresh Install Workflow

1. Install Arch Linux (base system)
2. `sudo pacman -S git stow` (install essentials outside chroot)
3. `git clone <your-repo-url> ~/dotfiles`
4. `cd ~/dotfiles && ./bootstrap.sh`

The bootstrap script will:
- Install stow + paru (if missing)
- Install all packages (official + AUR)
- Stow all dotfiles
- Initialize current theme from defaults
- Configure SSH signing
- Apply current theme

## Hyprland Config Loading Order (from `hyprland.conf`)

1. `hypr/bindings/media.conf`, `clipboard.conf`, `tiling.conf`, `utilities.conf`
2. `hypr/windows.conf` (sources `apps.conf`)
3. `themes/current/hyprland.conf` — theme vars (active border color, animations)
4. `hypr/monitors.conf`, `input.conf`, `bindings.conf`, `looknfeel.conf`
5. `hypr/autostart.conf` — startup apps (vicinae, snappy-switcher, hypridle, mako, waybar, fcitx5, swaybg, swayosd, etc.)
6. `hypr/envs.conf` — environment variables (Wayland, cursor, screenshot dirs)
7. `~/.local/state/toggles/hypr/*.conf` — dynamic toggle configs
8. `hypr/hyprbole-managed.conf` — hyprbole-managed sections

## Style Guide

- Two spaces for indentation, no tabs
- Bash scripts: `#!/bin/bash`, use `[[ ]]` for tests, `(( ))` for numeric comparisons
- Config files follow existing conventions in each directory
