#!/usr/bin/env bash

# Dotfiles installation script
# Creates symlinks from home directory to dotfiles repo

set -e  # Exit on error

if [ -z "$1" ]; then
    echo "Usage: install.sh <email>"
    exit 1
fi

GIT_EMAIL="$1"

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Function to create symlink with backup
link_to() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    # Backup existing file if it's not already a symlink
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up existing $dest to $dest.backup"
        mv "$dest" "$dest.backup"
    fi

    # Create symlink
    ln -sf "$src" "$dest"
    echo "Linked $dest -> $src"
}

link_file() {
    local filename="$1"
    local src="$DOTFILES_DIR/files/$filename"
    # If filename already starts with a dot, don't add another one
    if [[ "$filename" == .* ]]; then
        local dest="$HOME/$filename"
    else
        local dest="$HOME/.$filename"
    fi

    link_to "$src" "$dest"
}

# Check if files directory exists
if [ ! -d "$DOTFILES_DIR/files" ]; then
    echo "Error: $DOTFILES_DIR/files directory not found"
    echo "Please create a 'files' directory and add your dotfiles there"
    exit 1
fi

# Link all dotfiles in the files directory
# Files that don't start with "." get special handling below
shopt -s dotglob nullglob
for file in "$DOTFILES_DIR/files"/.*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        link_file "$filename"
    fi
done
shopt -u dotglob nullglob

# Link app-specific config files
EDITOR_KB="$DOTFILES_DIR/files/vscode-keybindings.json"
link_to "$EDITOR_KB" "$HOME/Library/Application Support/Code/User/keybindings.json"
link_to "$EDITOR_KB" "$HOME/Library/Application Support/Cursor/User/keybindings.json"
link_to "$DOTFILES_DIR/files/warp-keybindings.yaml" "$HOME/.warp/keybindings.yaml"
link_to "$DOTFILES_DIR/files/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_to "$DOTFILES_DIR/files/claude-keybindings.json" "$HOME/.claude/keybindings.json"
link_to "$DOTFILES_DIR/files/ghostty-config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# Link git subcommand scripts into ~/.local/bin
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES_DIR/bin"/git-*; do
    if [ -f "$script" ]; then
        link_to "$script" "$HOME/.local/bin/$(basename "$script")"
    fi
done

echo ""

# Check if .zshrc.local exists, create if not
if [ ! -f "$HOME/.zshrc.local" ]; then
    echo "Creating machine-specific zsh configuration file..."
    
    cat > "$HOME/.zshrc.local" << 'EOF'
# Machine-specific zsh configuration
# This file is not tracked in the dotfiles repo
# Add machine-specific PATH modifications, aliases, or other settings here

# Example:
# export PATH="$HOME/.local/bin:$PATH"
EOF
    
    echo "Created ~/.zshrc.local for machine-specific configuration"
else
    echo "~/.zshrc.local already exists, skipping"
fi

# Check if .gitconfig.local exists, create if not
if [ ! -f "$HOME/.gitconfig.local" ]; then
    echo ""
    echo "Creating machine-specific git configuration file..."

    cat > "$HOME/.gitconfig.local" << EOF
[user]
    email = $GIT_EMAIL
EOF

    echo "Created ~/.gitconfig.local with email: $GIT_EMAIL"
else
    echo "~/.gitconfig.local already exists, skipping"
fi

echo ""

# Install delta (git pager)
install_delta_via_dpkg() {
    local arch
    arch="$(dpkg --print-architecture)"
    local version
    version="$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')"
    if [ -z "$version" ]; then
        echo "Error: Could not determine latest delta version"
        return 1
    fi
    local deb="/tmp/git-delta.deb"
    curl -fsSL -o "$deb" "https://github.com/dandavison/delta/releases/download/${version}/git-delta_${version}_${arch}.deb"
    sudo dpkg -i "$deb"
    rm -f "$deb"
}

if command -v brew &>/dev/null; then
    echo "Installing delta via Homebrew..."
    brew install git-delta
elif command -v pacman &>/dev/null; then
    echo "Installing delta via pacman..."
    sudo pacman -S --noconfirm git-delta
elif command -v dnf &>/dev/null; then
    echo "Installing delta via dnf..."
    sudo dnf install -y git-delta
elif command -v zypper &>/dev/null; then
    echo "Installing delta via zypper..."
    sudo zypper install -y git-delta
elif command -v apt-get &>/dev/null; then
    echo "Installing delta via apt..."
    sudo apt-get install -y git-delta || {
        echo "apt-get failed, falling back to dpkg..."
        install_delta_via_dpkg || echo "Error: delta installation failed. Install manually: https://github.com/dandavison/delta"
    }
elif command -v dpkg &>/dev/null; then
    echo "Installing delta via dpkg..."
    install_delta_via_dpkg || echo "Error: delta installation failed. Install manually: https://github.com/dandavison/delta"
else
    echo "Error: No supported package manager found. Install delta manually: https://github.com/dandavison/delta"
fi

echo ""
echo "Dotfiles installation complete!"