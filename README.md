# Dotfiles

My personal configuration files.

## Installation

Clone this repository anywhere you like, then run `./install.sh`.

The install script will automatically detect its location and create symlinks from your home directory to all files in the `files/` directory.

## Updates

### If you changed files locally

No action needed

### If you changed files remotely

`git pull`

### If you added files

Run `./install.sh` again

## Machine-specific configuration

`./install.sh` automatically creates some "local" files that allow you to configure stuff without syncing:

- `~/.zshrc.local`
- `~/.gitconfig.local`
