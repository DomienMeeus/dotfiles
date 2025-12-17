#!/usr/bin/env bash
set -e

# ===========================
# CONFIG
# ===========================
DOTFILES_DIR="$HOME/.dotfiles"
BREWFILE="$DOTFILES_DIR/Brewfile"

# ===========================
# INSTALL HOMEBREW
# ===========================
if ! command -v brew &>/dev/null; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Homebrew is already installed."
fi

# Update Homebrew
brew update

# ===========================
# INSTALL STOW
# ===========================
if ! command -v stow &>/dev/null; then
	echo "Installing GNU Stow..."
	brew install stow
else
	echo "Stow is already installed."
fi

# ===========================
# INSTALL PACKAGES FROM BREWFILE
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
	cd "$DOTFILES_DIR"

	# Find all directories (ignore files like Brewfile)
	PACKAGES=()
	for item in *; do
		if [ -d "$item" ]; then
			PACKAGES+=("$item")
		fi
	done

	# Stow each package
	for pkg in "${PACKAGES[@]}"; do
		echo "Stowing $pkg..."
		stow "$pkg"
	done
else
	echo "Dotfiles directory $DOTFILES_DIR does not exist."
fi

echo "Setup complete!"
