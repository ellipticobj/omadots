# dotfiles

My Arch Linux dotfiles, managed with GNU Stow.

## Fresh Install

```bash
sudo pacman -S git stow
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

## Update Dotfiles

Edit files inside `~/dotfiles/`, then run:

```bash
stow -d ~/dotfiles -t ~ --restow .
```

## Package Management

```bash
./install.sh         # Install/update all packages
```

## Structure

```
~/dotfiles/
├── .bashrc                    # stowed to ~/.bashrc
├── .local/bin/                # stowed to ~/.local/bin/
├── .config/hypr/              # stowed to ~/.config/hypr/
├── .config/waybar/            # stowed to ~/.config/waybar/
├── .config/walker/            # stowed to ~/.config/walker/
── .config/elephant/          # stowed to ~/.config/elephant/
── .config/fish/              # stowed to ~/.config/fish/
├── .config/nvim/              # stowed to ~/.config/nvim/
├── ...                        # other .config/ packages
├── bootstrap.sh               # fresh install setup (git + stow + paru + packages + stow)
├── install.sh                 # package installer (git + stow + paru prereqs)
├── pkglist.txt                # official packages
── aurlist.txt                # AUR packages
└── gitssh.sh                  # SSH key setup
```
