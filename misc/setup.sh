#!/usr/bin/env bash
set -euo pipefail

# ===========================
# CONFIG
# ===========================
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BREWFILE="$DOTFILES_DIR/misc/Brewfile"

# ===========================
# OS DETECTION
# ===========================
OS="$(uname -s)"
case "$OS" in
Darwin) PLATFORM="macos" ;;
Linux) PLATFORM="linux" ;;
*)
	echo "Unsupported OS: $OS"
	exit 1
	;;
esac

# ===========================
# DOCKER DETECTION
# ===========================
is_docker() {
	[ -f /.dockerenv ] || grep -qE '(docker|containerd)' /proc/1/cgroup 2>/dev/null
}

# ===========================
# INSTALL HOMEBREW
# ===========================
if ! command -v brew &>/dev/null; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ===========================
# LOAD BREW ENV
# ===========================
if [ "$PLATFORM" = "linux" ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ===========================
# UPDATE BREW
# ===========================
brew update

# ===========================
# INSTALL FROM BREWFILE ONLY
# ===========================
if [ -f "$BREWFILE" ]; then
	echo "Installing packages from Brewfile..."
	brew bundle --file="$BREWFILE"
else
	echo "Brewfile not found at $BREWFILE"
	exit 1
fi

# ===========================
# STOW DOTFILES (if stow is in Brewfile)
# ===========================
if command -v stow &>/dev/null && [ -d "$DOTFILES_DIR" ]; then
	cd "$DOTFILES_DIR"

	for pkg in */; do
		pkg="${pkg%/}"
		echo "Stowing $pkg..."
		stow "$pkg"
	done
else
	echo "Skipping stow (not installed or dotfiles missing)"
fi

# ===========================
# SHELL HANDLING (OPTIONAL)
# ===========================
if command -v zsh &>/dev/null && ! is_docker; then
	ZSH_PATH="$(command -v zsh)"

	if ! grep -q "$ZSH_PATH" /etc/shells; then
		echo "Adding zsh to /etc/shells (sudo required)"
		echo "$ZSH_PATH" | sudo tee -a /etc/shells
	fi

	if [ "$SHELL" != "$ZSH_PATH" ]; then
		chsh -s "$ZSH_PATH"
	fi
else
	echo "Skipping shell setup"
fi

# ===========================
# DOCKER: EXEC ZSH IF PRESENT
# ===========================
if is_docker && command -v zsh &>/dev/null; then
	exec zsh
fi

echo "✅ Setup complete"
