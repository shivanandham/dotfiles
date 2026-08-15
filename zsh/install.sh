#!/usr/bin/env bash
# Bootstraps zsh + Oh My Zsh + powerlevel10k + plugins to match this config,
# then symlinks .zshrc and .p10k.zsh into place.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 2. Plugins used by this config: zsh-autosuggestions, zsh-syntax-highlighting
clone_if_missing() {
  local repo="$1" dest="$2"
  if [ ! -d "$dest" ]; then
    echo "Cloning $repo..."
    git clone --depth=1 "$repo" "$dest"
  fi
}
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting "$custom/plugins/zsh-syntax-highlighting"

# 3. Theme: powerlevel10k
clone_if_missing https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k"

# 4. Config files
ln -sf "$src/.zshrc" "$HOME/.zshrc"
ln -sf "$src/.p10k.zsh" "$HOME/.p10k.zsh"

echo "Done. Also make sure these are installed for the plugins/tools .zshrc references:"
echo "  - mise (https://mise.jdx.dev)"
echo "  - direnv (https://direnv.net)"
echo "  - jump  (https://github.com/gsamokovarov/jump)"
echo "Then restart your shell: exec zsh"
