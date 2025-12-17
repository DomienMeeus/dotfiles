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

echo "Platform: $PLATFORM"

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
# LOAD BREW ENV & ADD TO SHELL
# ===========================
if [ "$PLATFORM" = "linux" ]; then
	BREW_PREFIX="/home/linuxbrew/.linuxbrew"
	eval "$($BREW_PREFIX/bin/brew shellenv)"

	# Add to shell config files if not already present
	BREW_INIT='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

	for rcfile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish"; do
		if [ -f "$rcfile" ]; then
			if ! grep -q "linuxbrew" "$rcfile"; then
				echo "" >>"$rcfile"
				echo "# Homebrew" >>"$rcfile"
				if [[ "$rcfile" == *"fish"* ]]; then
					echo 'eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >>"$rcfile"
				else
					echo "$BREW_INIT" >>"$rcfile"
				fi
				echo "Added Homebrew to $rcfile"
			fi
		fi
	done
else
	eval "$(/opt/homebrew/bin/brew shellenv)"

	# Add to shell config files on macOS if not already present
	BREW_INIT='eval "$(/opt/homebrew/bin/brew shellenv)"'

	for rcfile in "$HOME/.zprofile" "$HOME/.bash_profile"; do
		if [ -f "$rcfile" ]; then
			if ! grep -q "/opt/homebrew/bin/brew shellenv" "$rcfile"; then
				echo "" >>"$rcfile"
				echo "# Homebrew" >>"$rcfile"
				echo "$BREW_INIT" >>"$rcfile"
				echo "Added Homebrew to $rcfile"
			fi
		fi
	done
fi

# ===========================
# UPDATE BREW
# ===========================
echo "Updating Homebrew..."
brew update

# ===========================
# INSTALL FROM BREWFILE
# ===========================
if [ -f "$BREWFILE" ]; then
	echo "Installing packages from Brewfile..."
	brew bundle --file="$BREWFILE"
else
	echo "Brewfile not found at $BREWFILE"
	exit 1
fi

# ===========================
# STOW DOTFILES
# ===========================
if command -v stow &>/dev/null && [ -d "$DOTFILES_DIR" ]; then
	cd "$DOTFILES_DIR"
	echo ""
	echo "Preparing to stow dotfiles..."

	# Clean up files that shouldn't be in dotfiles
	echo "Cleaning dotfiles directory..."
	for pkg in */; do
		pkg="${pkg%/}"
		# Remove .DS_Store files (macOS metadata)
		find "$pkg" -name ".DS_Store" -type f -delete 2>/dev/null || true
		# Remove .zsh_sessions if it exists
		[ -d "$pkg/.zsh_sessions" ] && rm -rf "$pkg/.zsh_sessions"
	done

	# Backup existing files that would conflict
	BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
	NEEDS_BACKUP=false

	for pkg in */; do
		pkg="${pkg%/}"
		if [ "$pkg" = "misc" ] || [ "$pkg" = "scripts" ]; then
			continue
		fi

		if [ -d "$pkg" ]; then
			find "$pkg" -type f | while read -r file; do
				home_file="${file#$pkg/}"
				home_path="$HOME/$home_file"

				# Check if file exists and is not a symlink to our dotfiles
				if [ -f "$home_path" ] && [ ! -L "$home_path" ]; then
					if [ "$NEEDS_BACKUP" = false ]; then
						echo ""
						echo "Found conflicting files. Creating backup at:"
						echo "  $BACKUP_DIR"
						mkdir -p "$BACKUP_DIR"
						NEEDS_BACKUP=true
					fi

					rel_path="${home_path#$HOME/}"
					backup_path="$BACKUP_DIR/$rel_path"
					backup_dir=$(dirname "$backup_path")

					mkdir -p "$backup_dir"
					mv "$home_path" "$backup_path"
					echo "  Backed up: ~/$rel_path"
				fi
			done
		fi
	done

	[ "$NEEDS_BACKUP" = true ] && echo ""

	echo "Stowing packages to $HOME..."
	for pkg in */; do
		pkg="${pkg%/}"
		if [ "$pkg" = "misc" ] || [ "$pkg" = "scripts" ]; then
			continue
		fi

		echo "  Stowing $pkg..."
		# Unstow first to clean up any old links
		stow --target="$HOME" --delete "$pkg" 2>/dev/null || true
		# Now stow fresh
		stow --target="$HOME" --restow "$pkg" 2>/dev/null && echo "    ✓ Success" || echo "    ⚠ Warning"
	done

	if [ "$NEEDS_BACKUP" = true ]; then
		echo ""
		echo "Old configs backed up to: $BACKUP_DIR"
	fi
else
	echo "Skipping stow (not installed or dotfiles missing)"
fi

# ===========================
# SHELL HANDLING
# ===========================
if command -v zsh &>/dev/null && ! is_docker; then
	ZSH_PATH="$(command -v zsh)"

	# Install oh-my-zsh if referenced in config but not installed
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		if grep -q "oh-my-zsh" "$HOME/.zshrc" 2>/dev/null; then
			echo ""
			echo "Installing oh-my-zsh..."
			sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
		fi
	fi

	# Install zsh-syntax-highlighting if available via brew
	if ! brew list zsh-syntax-highlighting &>/dev/null; then
		echo "Installing zsh-syntax-highlighting..."
		brew install zsh-syntax-highlighting
	fi

	# Add zsh to /etc/shells if needed
	if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
		echo ""
		echo "Adding zsh to /etc/shells (sudo required)"
		echo "$ZSH_PATH" | sudo tee -a /etc/shells
	fi

	# Change shell if needed
	if [ "$SHELL" != "$ZSH_PATH" ]; then
		echo "Changing default shell to zsh..."
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

echo ""
echo "✅ Setup complete for $PLATFORM"
