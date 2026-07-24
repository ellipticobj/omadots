#!/bin/bash
set -e

DOTFILES="$HOME/dotfiles"

echo "=== Dotfiles Bootstrap ==="

if [[ ! -d "$DOTFILES" ]]; then
  echo "ERROR: $DOTFILES not found."
  echo "Clone your dotfiles repo first:"
  echo "  git clone https://github.com/ellipticobj/dotfiles.git $DOTFILES"
  exit 1
fi

cd "$DOTFILES"

# --- Helper ---
install_pkglist() {
  local list="$1"
  local installer="$2"
  [[ ! -f "$list" ]] && return
  mapfile -t pkgs < "$list"
  ((${#pkgs[@]})) || return
  echo "  Installing ${#pkgs[@]} packages from $list ..."
  $installer "${pkgs[@]}" || true
}

# --- 1. Prerequisites: git, stow, base-devel, AUR helper ---
echo "[1/5] Installing prerequisites..."
sudo pacman -S --needed --noconfirm git stow base-devel

AUR_HELPER=""
for helper in paru yay; do
  command -v "$helper" &>/dev/null && AUR_HELPER="$helper" && break
done

if [[ -z "$AUR_HELPER" ]]; then
  echo "    No AUR helper found. Installing paru..."
  TMPDIR=$(mktemp -d)
  git clone https://aur.archlinux.org/paru.git "$TMPDIR/paru"
  (cd "$TMPDIR/paru" && makepkg -si --noconfirm)
  rm -rf "$TMPDIR"
  AUR_HELPER="paru"
fi
echo "    Tools: git, stow, $AUR_HELPER"

# --- 2. Install all packages ---
echo "[2/5] Installing packages..."
sudo pacman -Syu --noconfirm
install_pkglist "pkglist.txt" "sudo pacman -S --needed --noconfirm"
install_pkglist "aurlist.txt" "$AUR_HELPER -S --needed --noconfirm"

# --- 3. Stow dotfiles ---
echo "[3/5] Stowing dotfiles..."
stow -d "$DOTFILES" -t "$HOME" --restow . 2>&1

# --- 4. SSH signing ---
echo "[4/5] Setting up SSH signing..."
if [[ ! -f "$HOME/.ssh/id_ed25519.pub" ]]; then
  echo "    No SSH key found. Run './gitssh.sh' to generate one."
else
  git config --global gpg.format ssh 2>/dev/null || true
  git config --global user.signingkey "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
  git config --global commit.gpgsign true 2>/dev/null || true
fi

# --- 5. Set wallpaper ---
echo "[5/5] Setting default wallpaper..."
mkdir -p "$HOME/Pictures/Wallpapers"
if [[ ! -f "$HOME/Pictures/Wallpapers/default.png" ]]; then
  echo "    No default wallpaper found. Set one manually."
else
  if command -v swaybg &>/dev/null; then
    swaybg -i "$HOME/Pictures/Wallpapers/default.png" -m fill &
  fi
fi

echo ""
echo "=== Bootstrap complete! ==="
echo "Restart your shell: exec fish"
