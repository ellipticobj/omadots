#!/bin/bash
# Fresh Arch Linux system setup script
# Run as root from a fresh Arch install (after base system is installed)
set -e

USER_NAME="${1:-el}"
HOSTNAME="${2:-yuri}"

echo "=== Arch System Setup ==="
echo "User: $USER_NAME"
echo "Hostname: $HOSTNAME"

# ============================================================
# 1. Locale and Keyboard
# ============================================================
echo "[1/20] Setting locale and keyboard..."

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

cat > /etc/vconsole.conf << EOF
FONT=default8x16
KEYMAP=dvorak
XKBLAYOUT=us
XKBMODEL=pc105
XKBVARIANT=dvorak
XKBOPTIONS=terminate:ctrl_alt_bksp
EOF

echo "$HOSTNAME" > /etc/hostname

cat > /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "us"
        Option "XkbModel" "pc105"
        Option "XkbVariant" "dvorak"
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF

# ============================================================
# 2. Pacman Configuration
# ============================================================
echo "[2/20] Configuring pacman..."

cat > /etc/pacman.conf << EOF
# See the pacman.conf(5) manpage for option and repository directives

[options]
Color
ILoveCandy
VerbosePkgLists
HoldPkg = pacman glibc
Architecture = auto
CheckSpace
ParallelDownloads = 5
DownloadUser = alpm

SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

cat > /etc/pacman.d/mirrorlist << EOF
Server = https://stable-mirror.omarchy.org/\$repo/os/\$arch
EOF

# ============================================================
# 3. Install Packages
# ============================================================
echo "[3/20] Installing packages..."

pacman -Syu --noconfirm

# Install from pkglist
while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  pacman -S --needed --noconfirm "$pkg" 2>/dev/null || echo "  [skip] $pkg"
done < /home/$USER_NAME/dotfiles/pkglist.txt

# Install AUR helper (paru)
if ! command -v paru &>/dev/null; then
  echo "  Installing paru..."
  pacman -S --needed --noconfirm --asdeps git base-devel
  TMPDIR=$(mktemp -d)
  git clone https://aur.archlinux.org/paru.git "$TMPDIR/paru"
  (cd "$TMPDIR/paru" && makepkg -si --noconfirm)
  rm -rf "$TMPDIR"
fi

# Install AUR packages
while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  paru -S --needed --noconfirm "$pkg" 2>/dev/null || echo "  [skip] $pkg"
done < /home/$USER_NAME/dotfiles/aurlist.txt

# ============================================================
# 4. Boot Configuration (systemd-boot)
# ============================================================
echo "[4/20] Configuring boot..."

# Install systemd-boot if not already installed
bootctl install 2>/dev/null || true

# Boot entry
mkdir -p /boot/loader/entries
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux (zen)
linux   /vmlinuz-linux-zen
initrd  /amd-ucode.img
initrd  /initramfs-linux-zen.img
options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/disk/by-partlabel/root 2>/dev/null || echo "ROOT_PARTUUID") rw
EOF

# Loader config
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 120
console-mode keep
EOF

# ============================================================
# 5. mkinitcpio
# ============================================================
echo "[5/20] Configuring mkinitcpio..."

cat > /etc/mkinitcpio.conf << 'EOF'
MODULES=(nvme nvme_core vmd)
BINARIES=()
FILES=()
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)
COMPRESSION="zstd"
COMPRESSION_OPTIONS=("-7")
EOF

mkinitcpio -P

# ============================================================
# 6. Module Configuration
# ============================================================
echo "[6/20] Configuring kernel modules..."

cat > /etc/modprobe.d/nvidia.conf << EOF
options nvidia_drm modeset=1
EOF

cat > /etc/modprobe.d/disable-usb-autosuspend.conf << EOF
options usbcore autosuspend=-1
EOF

cat > /etc/modprobe.d/hid_apple.conf << EOF
options hid_apple fnmode=2
EOF

# ============================================================
# 7. Systemd Services
# ============================================================
echo "[7/20] Enabling systemd services..."

# System services
systemctl enable bluetooth.service
systemctl enable cups.service
systemctl enable cups-browsed.service
systemctl enable iwd.service
systemctl enable power-profiles-daemon.service
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service
systemctl enable systemd-timesyncd.service
systemctl enable ufw.service
systemctl enable avahi-daemon.service

# User services (will be enabled after user creation)
# elephant, wireplumber, xdg-user-dirs

# ============================================================
# 8. SDDM Configuration
# ============================================================
echo "[8/20] Configuring SDDM..."

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/autologin.conf << EOF
[Autologin]
User=$USER_NAME
Session=hyprland

[Theme]
Current=maldives
EOF

# Install SDDM theme
mkdir -p /usr/share/sddm/themes/maldives
# Copy from system-defaults if available
if [[ -d /home/$USER_NAME/.local/share/system-defaults/default/sddm/omarchy ]]; then
  cp -r /home/$USER_NAME/.local/share/system-defaults/default/sddm/omarchy/* /usr/share/sddm/themes/maldives/ 2>/dev/null || true
fi

systemctl enable sddm.service

# ============================================================
# 9. Plymouth Configuration
# ============================================================
echo "[9/20] Configuring Plymouth..."

if [[ -d /home/$USER_NAME/.local/share/system-defaults/default/plymouth ]]; then
  cp -r /home/$USER_NAME/.local/share/system-defaults/default/plymouth/* /usr/share/plymouth/themes/ 2>/dev/null || true
  plymouth-set-default-theme -R omarchy 2>/dev/null || true
fi

# ============================================================
# 10. NSSwitch Configuration
# ============================================================
echo "[10/20] Configuring nsswitch..."

cat > /etc/nsswitch.conf << EOF
# Name Service Switch configuration file.

passwd: files systemd
group: files [SUCCESS=merge] systemd
shadow: files systemd
gshadow: files systemd

publickey: files

hosts: mymachines mdns_minimal [NOTFOUND=return] resolve files myhostname dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

netgroup: files
EOF

# ============================================================
# 11. Security Limits
# ============================================================
echo "[11/20] Configuring security limits..."

mkdir -p /etc/security/limits.d
cat > /etc/security/limits.d/10-gamemode.conf << EOF
@gamemode - nice -10
EOF

# ============================================================
# 12. Udev Rules
# ============================================================
echo "[12/20] Configuring udev rules..."

mkdir -p /etc/udev/rules.d

cat > /etc/udev/rules.d/99-power-profile.rules << EOF
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="/usr/bin/systemd-run --no-block --collect --unit=power-profile /usr/local/bin/powerprofiles-set"
SUBSYSTEM=="power_supply", ATTR{type}=="USB", RUN+="/usr/bin/systemd-run --no-block --collect --unit=power-profile /usr/local/bin/powerprofiles-set"
EOF

cat > /etc/udev/rules.d/99-wifi-powersave.rules << EOF
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/systemd-run --no-block --collect --unit=wifi-powersave-on /usr/local/bin/wifi-powersave on"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/systemd-run --no-block --collect --unit=wifi-powersave-off /usr/local/bin/wifi-powersave off"
EOF

cat > /etc/udev/rules.d/framework16-qmk-hid.rules << EOF
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", MODE="0660", TAG+="uaccess"
EOF

# ============================================================
# 13. Systemd Overrides
# ============================================================
echo "[13/20] Configuring systemd overrides..."

# User service timeout
mkdir -p /etc/systemd/system/user@.service.d
cat > /etc/systemd/system/user@.service.d/no-block-boot.conf << EOF
[Unit]
DefaultDependencies=no
EOF

# Docker service
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/no-block-boot.conf << EOF
[Unit]
DefaultDependencies=no
EOF

# Faster shutdown
mkdir -p /etc/systemd/system.conf.d
cat > /etc/systemd/system.conf.d/faster-shutdown.conf << EOF
[Manager]
DefaultTimeoutStopSec=5s
EOF

# System sleep scripts
mkdir -p /etc/systemd/system-sleep

cat > /etc/systemd/system-sleep/force-igpu << 'SCRIPT'
#!/bin/bash
case "$1" in
  pre)
    if [[ $2 == "hibernate" ]]; then
      /usr/bin/supergfxctl -m Vfio
      sleep 1
    fi
    ;;
  post)
    sleep 4
    /usr/bin/supergfxctl -m Vfio
    sleep 1
    /usr/bin/supergfxctl -m Integrated
    ;;
esac
SCRIPT
chmod +x /etc/systemd/system-sleep/force-igpu

cat > /etc/systemd/system-sleep/keyboard-backlight << 'SCRIPT'
#!/bin/bash
if [[ $1 == "pre" && $2 == "hibernate" ]]; then
  device=""
  for candidate in /sys/class/leds/*kbd_backlight*; do
    if [[ -e "$candidate" ]]; then
      device="$(basename "$candidate")"
      break
    fi
  done
  if [[ -n "$device" ]]; then
    brightnessctl -d "$device" set 0 >/dev/null 2>&1
  fi
fi
SCRIPT
chmod +x /etc/systemd/system-sleep/keyboard-backlight

cat > /etc/systemd/system-sleep/unmount-fuse << 'SCRIPT'
#!/bin/bash
if [[ $1 == "pre" ]]; then
  while IFS=' ' read -r _ mountpoint fstype _; do
    if [[ $fstype == fuse.gvfsd-fuse ]]; then
      mountpoint=$(printf '%b' "$mountpoint")
      fusermount3 -uz "$mountpoint" 2>/dev/null || fusermount -uz "$mountpoint" 2>/dev/null || true
    fi
  done < /proc/mounts
fi
if [[ $1 == "post" ]]; then
  (sleep 2 && systemctl --user restart gvfs-daemon.service) &
fi
SCRIPT
chmod +x /etc/systemd/system-sleep/unmount-fuse

# ============================================================
# 14. User Services
# ============================================================
echo "[14/20] Configuring user services..."

mkdir -p /etc/systemd/user

cat > /etc/systemd/user/pipewire-session-manager.service << EOF
[Unit]
Description=Multimedia Service Session Manager
After=pipewire.service dbus.service
BindsTo=pipewire.service
Conflicts=pipewire-media-session.service

[Service]
LockPersonality=yes
MemoryDenyWriteExecute=yes
NoNewPrivileges=yes
SystemCallArchitectures=native
SystemCallFilter=@system-service mincore
Type=simple
ExecStart=/usr/bin/wireplumber
Restart=on-failure
Slice=session.slice
Environment=GIO_USE_VFS=local

[Install]
WantedBy=pipewire.service
Alias=pipewire-session-manager.service
EOF

# Enable user service targets
mkdir -p /etc/systemd/user/graphical-session-pre.target.wants
ln -sf /usr/lib/systemd/user/xdg-user-dirs.service /etc/systemd/user/graphical-session-pre.target.wants/

mkdir -p /etc/systemd/user/sockets.target.wants
ln -sf /usr/lib/systemd/user/gnome-keyring-daemon.socket /etc/systemd/user/sockets.target.wants/ 2>/dev/null || true
ln -sf /usr/lib/systemd/user/pipewire.socket /etc/systemd/user/sockets.target.wants/
ln -sf /usr/lib/systemd/user/pipewire-pulse.socket /etc/systemd/user/sockets.target.wants/

# ============================================================
# 15. UFW Configuration
# ============================================================
echo "[15/20] Configuring UFW..."

ufw enable
ufw default deny incoming
ufw default allow outgoing

# ============================================================
# 16. Wireplumber Configuration
# ============================================================
echo "[16/20] Configuring Wireplumber..."

mkdir -p /etc/wireplumber/wireplumber.conf.d

cat > /etc/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf << EOF
## Use software volume control for all ALSA devices.
monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "~alsa_card.*"
      }
    ]
    actions = {
      update-props = {
        api.alsa.soft-mixer = true
      }
    }
  }
]
EOF

# ============================================================
# 17. GPG Configuration
# ============================================================
echo "[17/20] Configuring GPG..."

mkdir -p /etc/pacman.d/gnupg

cat > /etc/pacman.d/gnupg/dirmngr.conf << EOF
keyserver hkps://keyserver.ubuntu.com
keyserver hkps://pgp.surfnet.nl
keyserver hkps://keys.mailvelope.com
keyserver hkps://keyring.debian.org
keyserver hkps://pgp.mit.edu

connect-quick-timeout 4
EOF

# ============================================================
# 18. Pacman Hook for Walker
# ============================================================
echo "[18/20] Configuring pacman hooks..."

mkdir -p /etc/pacman.d/hooks

cat > /etc/pacman.d/hooks/walker-restart.hook << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = walker
Target = walker-debug
Target = elephant*

[Action]
Description = Restarting Walker services after system update
When = PostTransaction
Exec = /usr/local/bin/restart-walker
EOF

# ============================================================
# 19. Create User and Home Directories
# ============================================================
echo "[19/20] Setting up user..."

# Create user if not exists
if ! id -u "$USER_NAME" &>/dev/null; then
  useradd -m -G wheel,audio,video,network,storage,power,libvirt,docker -s /usr/bin/fish "$USER_NAME"
  echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME
fi

# Create home directories
mkdir -p /home/$USER_NAME/{Pictures/{Screenshots,Wallpapers},Documents,Downloads,Music,Videos,.config,.local/bin,.ssh}
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME

# Set default shell
chsh -s /usr/bin/fish $USER_NAME 2>/dev/null || true

# ============================================================
# 20. Stow Dotfiles and Final Setup
# ============================================================
echo "[20/20] Setting up dotfiles..."

cd /home/$USER_NAME/dotfiles

# Install prerequisites
pacman -S --needed --noconfirm git stow

# Stow dotfiles
stow -d /home/$USER_NAME/dotfiles -t /home/$USER_NAME --restow .

# Setup SSH
if [[ -f /home/$USER_NAME/dotfiles/gitssh.sh ]]; then
  su - $USER_NAME -c "/home/$USER_NAME/dotfiles/gitssh.sh" 2>/dev/null || true
fi

# Initialize theme system
mkdir -p /home/$USER_NAME/.config/themes/current
if [[ -d /home/$USER_NAME/.config/themes/blackwall ]]; then
  cp -r /home/$USER_NAME/.config/themes/blackwall/* /home/$USER_NAME/.config/themes/current/
  echo "blackwall" > /home/$USER_NAME/.config/themes/current/theme.name
fi

# Set permissions
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.config
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.local

# Enable user services
su - $USER_NAME -c "systemctl --user enable wireplumber.service"
su - $USER_NAME -c "systemctl --user enable xdg-user-dirs.service"

echo ""
echo "=== Setup Complete! ==="
echo "Reboot to apply changes: reboot"
echo ""
echo "After reboot:"
echo "  1. Login as $USER_NAME"
echo "  2. Run: cd ~/dotfiles && ./install.sh"
echo "  3. Set wallpaper: theme-bg-set ~/Pictures/Wallpapers/your-wallpaper.png"
echo "  4. Apply theme: theme-set blackwall"
