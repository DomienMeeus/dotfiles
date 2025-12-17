#!/usr/bin/env bash
set -euo pipefail

# ===========================
# CONFIG
# ===========================
DOTFILES_DIR="$HOME/.dotfiles"
BREWFILE="$DOTFILES_DIR/misc/Brewfile"

# ===========================
# OS DETECTION
# ===========================
OS="$(uname -s)"

case "$OS" in
Darwin)
	PLATFORM="macos"
	;;
Linux)
	PLATFORM="linux"
	;;
*)
	echo "Unsupported OS: $OS"
	exit 1
	;;
esac

echo "Detected platform: $PLATFORM"

# ===========================
# INSTALL HOMEBREW
# ===========================
if ! command -v brew &>/dev/null; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Homebrew already installed."
fi

# ===========================
# ENSURE BREW IN PATH
# ===========================
if [ "$PLATFORM" = "linux" ]; then
	BREW_PREFIX="/home/linuxbrew/.linuxbrew"
else
	BREW_PREFIX="/opt/homebrew"
fi

if ! command -v brew &>/dev/null; then
	echo "Adding Homebrew to PATH..."
	eval "$("$BREW_PREFIX/bin/brew" shellenv)"
fi

# ===========================
# UPDATE BREW
# ===========================
brew update

# ===========================
# INSTALL ESSENTIALS
# ===========================
brew install stow zsh git curl

# ===========================
# SET ZSH AS DEFAULT SHELL
# ===========================
ZSH_PATH="$(brew --prefix)/bin/zsh"

if ! grep -q "$ZSH_PATH" /etc/shells; then
	echo "Adding zsh to /etc/shells (sudo required)"
	echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$ZSH_PATH" ]; then
	echo "Setting zsh as default shell..."
	chsh -s "$ZSH_PATH"
else
	echo "zsh is already the default shell."
fi

# ===========================
# INSTALL FROM BREWFILE
# ===========================
if [ -f "$BREWFILE" ]; then
	echo "Installing packages from Brewfile..."
	brew bundle --file="$BREWFILE"
else
	echo "No Brewfile found at $BREWFILE"
fi

# ===========================
# STOW DOTFILES
# ===========================
if [ -d "$DOTFILES_DIR" ]; then
	echo "Stowing dotfiles..."
	cd "$DOTFILES_DIR"

	for pkg in */; do
		pkg="${pkg%/}"
		echo "Stowing $pkg..."
		stow "$pkg"
	done
else
	echo "Dotfiles directory not found: $DOTFILES_DIR"
fi

# ===========================
# DONE
# ===========================
echo "✅ Setup complete! Restart your terminal to start using zsh."
