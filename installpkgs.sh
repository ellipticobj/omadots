sudo pacman -Syyu

while read -r pkg; do
  sudo pacman -S --needed --noconfirm "$pkg" || echo "$pkg not found" | tee -a mising.txt
done < pkglist.txt

while read -r pkg; do
  yay -S --needed --noconfirm "$pkg" || echo "$pkg not found" | tee -a missing.txt
done < aurlist.txt

echo "\n\nmissing packages at missing.txt"
