# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's Included

- **zsh** - Zsh configuration with Oh My Zsh, custom prompt, and plugins
- **nvim** - Neovim configuration
- **yazi** - Terminal file manager configuration
- **zellij** - Terminal multiplexer configuration
- **kitty** - Terminal emulator configuration

## Prerequisites

```bash
sudo dnf install stow git
```

## Installation

### Fresh Machine Setup

1. Clone this repository:
```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

2. Stow the packages you want:
```bash
# Install all configs
stow */

# Or install specific ones
stow zsh nvim kitty
```

### Existing Machine (with configs already)

If you already have config files, back them up first:

```bash
mkdir -p ~/config-backup
mv ~/.zshrc ~/config-backup/
mv ~/.config/{nvim,yazi,zellij,kitty} ~/config-backup/

cd ~/dotfiles
stow */
```

## Usage

### Adding Changes

Just edit files in `~/dotfiles/`. Changes apply immediately via symlinks.

```bash
nvim ~/dotfiles/zsh/.zshrc
# Changes are instantly active in ~/.zshrc
```

### Adding New Configs

1. Create package directory structure:
```bash
mkdir -p ~/dotfiles/package-name/.config/package-name
```

2. Move your config:
```bash
mv ~/.config/package-name/* ~/dotfiles/package-name/.config/package-name/
```

3. Stow it:
```bash
cd ~/dotfiles
stow package-name
```

### Removing Configs

```bash
cd ~/dotfiles
stow -D package-name  # Removes symlinks, keeps files in dotfiles
```

## How Stow Works

Stow creates symlinks from your home directory to files in this repo.

Example structure:
```
~/dotfiles/zsh/.zshrc  →  symlinked to  →  ~/.zshrc
~/dotfiles/nvim/.config/nvim/  →  symlinked to  →  ~/.config/nvim/
```

## Verifying Installation

Check that symlinks were created correctly:

```bash
ls -la ~/.zshrc
ls -la ~/.config/nvim
```

You should see `->` arrows pointing to `~/dotfiles/...`

## Git Workflow

```bash
cd ~/dotfiles

# Check status
git status

# Commit changes
git add .
git commit -m "Update nvim config"

# Push to remote
git push

# Pull on another machine
git pull
stow */
```

## Troubleshooting

**Error: "existing target is not a symlink"**
- You have existing config files. Back them up and remove them first.

**Stow creates files in wrong location**
- Make sure you run `stow` from `~/dotfiles` directory
- Check your package structure matches: `package-name/.config/...` or `package-name/.filename`

## Dependencies

### Zsh Setup
```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
sudo dnf install zsh-autosuggestions zsh-syntax-highlighting fzf zoxide

# Install GitHub CLI
sudo dnf install gh
```

### Other Tools
```bash
sudo dnf install neovim yazi zellij kitty
```
