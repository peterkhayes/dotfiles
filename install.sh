#!/usr/bin/env bash

# Dotfiles installation script
# Creates symlinks from home directory to dotfiles repo

set -e  # Exit on error

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Function to create symlink with backup
link_file() {
    local filename="$1"
    local src="$DOTFILES_DIR/files/$filename"
    local dest="$HOME/.$filename"
    
    # Backup existing file if it's not already a symlink
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up existing $dest to $dest.backup"
        mv "$dest" "$dest.backup"
    fi
    
    # Create symlink
    ln -sf "$src" "$dest"
    echo "Linked $dest -> $src"
}

# Check if files directory exists
if [ ! -d "$DOTFILES_DIR/files" ]; then
    echo "Error: $DOTFILES_DIR/files directory not found"
    echo "Please create a 'files' directory and add your dotfiles there"
    exit 1
fi

# Link all files in the files directory
for file in "$DOTFILES_DIR/files"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        link_file "$filename"
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
    echo "Setting up machine-specific git configuration..."
    read -p "Enter your git email address: " git_email
    
    cat > "$HOME/.gitconfig.local" << EOF
[user]
    email = $git_email
EOF
    
    echo "Created ~/.gitconfig.local with email: $git_email"
else
    echo "~/.gitconfig.local already exists, skipping"
fi

echo ""
echo "Dotfiles installation complete!"