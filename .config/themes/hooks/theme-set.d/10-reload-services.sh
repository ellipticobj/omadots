#!/bin/bash
# Reload all services after theme change

THEMES_DIR="$HOME/.config/themes"
CURRENT="$THEMES_DIR/current"

# Set background symlink if not set
if [[ ! -e "$CURRENT/background" ]] && [[ -d "$CURRENT/backgrounds" ]]; then
  first_bg=$(ls "$CURRENT/backgrounds" | grep -E '\.(jpg|jpeg|png|gif|webp)$' | head -1)
  if [[ -n "$first_bg" ]]; then
    ln -sf "$CURRENT/backgrounds/$first_bg" "$CURRENT/background"
  fi
fi

# Restart swaybg (wallpaper)
if pgrep -x swaybg >/dev/null; then
  pkill -x swaybg
  sleep 0.3
  if [[ -e "$CURRENT/background" ]]; then
    swaybg -i "$CURRENT/background" -m fill &
    disown
  fi
fi

# Reload waybar
if pgrep -x waybar >/dev/null; then
  waybar msg reload 2>/dev/null || {
    pkill -x waybar
    sleep 0.3
    waybar &
    disown
  }
fi

# Reload mako
if pgrep -x mako >/dev/null; then
  makoctl reload 2>/dev/null || {
    pkill -x mako
    sleep 0.3
    mako &
    disown
  }
fi

# Reload hyprland
if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
  hyprctl reload 2>/dev/null
fi

# Reload swayosd
if pgrep -x swayosd >/dev/null; then
  pkill -x swayosd
  sleep 0.3
  swayosd-server &
  disown
fi

# Reload kitty
if pgrep -x kitty >/dev/null; then
  for pid in $(pgrep -x kitty); do
    kill -SIGUSR1 "$pid" 2>/dev/null
  done
fi

# Apply GTK settings
if [[ -f "$CURRENT/gtk.css" ]]; then
  mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
  cp "$CURRENT/gtk.css" "$HOME/.config/gtk-3.0/gtk.css" 2>/dev/null
  cp "$CURRENT/gtk.css" "$HOME/.config/gtk-4.0/gtk.css" 2>/dev/null
fi

# Apply GNOME color scheme
if [[ -f "$CURRENT/light.mode" ]]; then
  gsettings set org.gnome.desktop.interface color-scheme "prefer-light" 2>/dev/null
else
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null
fi

# Apply GNOME icon theme
if [[ -f "$CURRENT/icons.theme" ]]; then
  icon_theme=$(cat "$CURRENT/icons.theme")
  gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" 2>/dev/null
fi
