# Git subcommands (git-fresh, git-sync, git-tidy) live in ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# Machine-specific configuration
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
export MISE_ENV=macos # loads mise.macos.toml
eval "$(mise activate zsh)"
export PKG_CONFIG_PATH="/opt/homebrew/opt/zlib/lib/pkgconfig:/usr/local/opt/zlib/lib/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig:/usr/local/opt/openssl@3/lib/pkgconfig:$PKG_CONFIG_PATH"
eval "$(rbenv init -)"
export RACK_ENV=development
export AWS_CONFIG_FILE="$HOME/figma/figma/config/aws/sso_config"

# Aliases
alias wifi-mesh-reset='sudo /usr/bin/wdutil disassociate'
