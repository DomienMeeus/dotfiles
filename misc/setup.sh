#!/usr/bin/env bash
# Debug script to check your dotfiles structure and stow status

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo "DOTFILES STRUCTURE CHECK"
echo "========================================"
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Check directory structure
echo "Directory structure:"
cd "$DOTFILES_DIR"
ls -la

echo ""
echo "========================================"
echo "CHECKING EACH PACKAGE"
echo "========================================"

for pkg in */; do
	pkg="${pkg%/}"
	echo ""
	echo "Package: $pkg"
	echo "Contents:"
	tree -L 3 "$pkg" 2>/dev/null || find "$pkg" -maxdepth 3 -type f | head -10
done

echo ""
echo "========================================"
echo "CHECKING STOW STATUS"
echo "========================================"

if ! command -v stow &>/dev/null; then
	echo "❌ stow is not installed"
	exit 1
fi

echo "stow version: $(stow --version | head -1)"
echo ""

# Check what's currently stowed
echo "Checking what's currently linked to $HOME:"
for pkg in */; do
	pkg="${pkg%/}"
	if [ "$pkg" = "misc" ] || [ "$pkg" = "scripts" ]; then
		continue
	fi

	echo ""
	echo "Checking $pkg:"

	# Find files in the package
	if [ -d "$pkg" ]; then
		find "$pkg" -type f | while read -r file; do
			# Convert package path to home path
			home_file="${file#$pkg/}"
			home_path="$HOME/$home_file"

			if [ -L "$home_path" ]; then
				target=$(readlink "$home_path")
				if [[ "$target" == *"$DOTFILES_DIR"* ]]; then
					echo "  ✓ $home_file → linked"
				else
					echo "  ⚠ $home_file → linked but NOT to dotfiles"
				fi
			elif [ -f "$home_path" ]; then
				echo "  ❌ $home_file → exists as regular file (conflict!)"
			else
				echo "  ⚠ $home_file → not linked"
			fi
		done
	fi
done

echo ""
echo "========================================"
echo "POTENTIAL CONFLICTS"
echo "========================================"

# Check for files that would conflict with stow
for pkg in */; do
	pkg="${pkg%/}"
	if [ "$pkg" = "misc" ] || [ "$pkg" = "scripts" ]; then
		continue
	fi

	if [ -d "$pkg" ]; then
		find "$pkg" -type f | while read -r file; do
			home_file="${file#$pkg/}"
			home_path="$HOME/$home_file"

			if [ -f "$home_path" ] && [ ! -L "$home_path" ]; then
				echo "⚠️  Conflict: $home_path exists as regular file"
				echo "   To fix: mv '$home_path' '$home_path.backup'"
			fi
		done
	fi
done

echo ""
echo "========================================"
echo "RECOMMENDED ACTIONS"
echo "========================================"
echo ""
echo "If you have conflicts, you can:"
echo "1. Backup existing files:"
echo "   cd ~"
echo "   mv .zshrc .zshrc.backup"
echo "   mv .zshenv .zshenv.backup"
echo ""
echo "2. Re-stow from dotfiles directory:"
echo "   cd $DOTFILES_DIR"
echo "   stow --target=$HOME zsh  # or whatever your package is named"
echo ""
echo "3. Or use --adopt to merge existing files into dotfiles:"
echo "   cd $DOTFILES_DIR"
echo "   stow --adopt --target=$HOME zsh"
echo "   (then review changes with git diff)"
