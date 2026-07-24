#!/bin/bash
set -e

MISSING=$(mktemp)
trap 'rm -f "$MISSING"' EXIT

# --- Install prerequisites ---
echo "[prerequisites] Installing git, stow, base-devel..."
sudo pacman -S --needed --noconfirm git stow base-devel

# --- Ensure AUR helper (prefer paru) ---
AUR_HELPER=""
if command -v paru &>/dev/null; then
  AUR_HELPER="paru"
elif command -v yay &>/dev/null; then
  AUR_HELPER="yay"
else
  echo "[aur] No AUR helper found. Installing paru..."
  sudo pacman -S --needed --noconfirm --asdeps git base-devel
  TMPDIR=$(mktemp -d)
  git clone https://aur.archlinux.org/paru.git "$TMPDIR/paru"
  (cd "$TMPDIR/paru" && makepkg -si --noconfirm)
  rm -rf "$TMPDIR"
  AUR_HELPER="paru"
fi
echo "[aur] Using $AUR_HELPER"

# --- Sync repos ---
sudo pacman -Sy --noconfirm

# --- Official packages ---
echo "[pacman] Installing official packages..."
while read -r pkg; do
  [[ -z "$pkg" ]] && continue
  sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null \
    || echo "$pkg" >> "$MISSING"
done < pkglist.txt

# --- AUR packages ---
echo "[aur] Installing AUR packages..."
while read -r pkg; do
  [[ -z "$pkg" ]] && continue
  $AUR_HELPER -S --needed --noconfirm "$pkg" 2>/dev/null \
    || echo "$pkg" >> "$MISSING"
done < aurlist.txt

# --- Report ---
if [[ -s "$MISSING" ]]; then
  echo -e "\nMissing packages:"
  cat "$MISSING"
else
  echo -e "\nAll packages installed successfully."
fi
