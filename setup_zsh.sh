#!/bin/bash
# ======================================================================
# ZSH Setup Script for Ubuntu
# ======================================================================
# This script will install and configure zsh with Oh My Zsh,
# Powerlevel10k theme, and recommended plugins.
#
# Usage: bash setup_zsh.sh
# ======================================================================

set -e  # Exit on error

echo "======================================================================"
echo "ZSH Setup for Ubuntu - Starting Installation"
echo "======================================================================"

TMUX_CONF="$HOME/.tmux.conf"
TMUX_MARKER_BEGIN="# >>> zsh_stuff tmux defaults >>>"
TMUX_MARKER_END="# <<< zsh_stuff tmux defaults <<<"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_TEMPLATE="$SCRIPT_DIR/.zshrc.template"

# Check if running on Ubuntu/Debian
if ! command -v apt-get &> /dev/null; then
    echo "Error: This script is designed for Ubuntu/Debian systems"
    exit 1
fi

# Update package lists
echo ""
echo "[1/14] Updating package lists..."
echo ""
sudo apt-get update

# Install zsh
echo ""
echo "[2/14] Installing zsh..."
if ! command -v zsh &> /dev/null; then
    echo ""
    sudo apt-get install -y zsh
    echo "✓ zsh installed successfully"
else
    echo "✓ zsh is already installed"
fi

# Install Oh My Zsh
echo ""
echo "[3/14] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed successfully"
else
    echo "✓ Oh My Zsh is already installed"
fi

# Install Powerlevel10k theme
echo ""
echo "[4/14] Installing Powerlevel10k theme..."
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    echo "✓ Powerlevel10k installed successfully"
else
    echo "✓ Powerlevel10k is already installed"
fi

# Install zsh-autosuggestions
echo ""
echo "[5/14] Installing zsh-autosuggestions plugin..."
AUTOSUGGEST_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$AUTOSUGGEST_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGEST_DIR"
    echo "✓ zsh-autosuggestions installed successfully"
else
    echo "✓ zsh-autosuggestions is already installed"
fi

# Install zsh-syntax-highlighting
echo ""
echo "[6/14] Installing zsh-syntax-highlighting plugin..."
SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$SYNTAX_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_DIR"
    echo "✓ zsh-syntax-highlighting installed successfully"
else
    echo "✓ zsh-syntax-highlighting is already installed"
fi

# Install zsh-history-substring-search
echo ""
echo "[7/14] Installing zsh-history-substring-search plugin..."
HISTORY_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"
if [ ! -d "$HISTORY_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search "$HISTORY_DIR"
    echo "✓ zsh-history-substring-search installed successfully"
else
    echo "✓ zsh-history-substring-search is already installed"
fi

# Install recommended tools
echo ""
echo "[8/14] Installing recommended tools..."
TOOLS_TO_INSTALL=""

# Check for fzf
if ! command -v fzf &> /dev/null; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL fzf"
fi

# Check for fd-find (fd)
if ! command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL fd-find"
fi

# Check for bat
if ! command -v bat &> /dev/null && ! command -v batcat &> /dev/null; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL bat"
fi

# Check for tree
if ! command -v tree &> /dev/null; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL tree"
fi

# Check for tmux
if ! command -v tmux &> /dev/null; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL tmux"
fi

# Check for ripgrep (rg)
if ! command -v rg &> /dev/null; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL ripgrep"
fi

# Check for eza (best effort: not available in all Ubuntu/Debian repos)
if ! command -v eza &> /dev/null; then
    if apt-cache show eza &> /dev/null; then
        TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL eza"
    else
        echo "- Skipping eza (package not found in current apt repositories)"
    fi
fi

# Check for delta (best effort package name on Debian/Ubuntu is git-delta)
if ! command -v delta &> /dev/null; then
    if apt-cache show git-delta &> /dev/null; then
        TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL git-delta"
    else
        echo "- Skipping git-delta (package not found in current apt repositories)"
    fi
fi

# Clipboard tools for tmux copy-mode integration (install best effort)
if ! command -v xclip &> /dev/null && ! command -v wl-copy &> /dev/null; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL xclip wl-clipboard"
fi

if [ -n "$TOOLS_TO_INSTALL" ]; then
    echo ""
    sudo apt-get install -y $TOOLS_TO_INSTALL
    echo "✓ Recommended tools installed"
else
    echo "✓ All recommended tools are already installed"
fi

# Create symlinks for Ubuntu-specific tool names
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -sf $(which fdfind) ~/.local/bin/fd
    echo "✓ Created 'fd' symlink for fdfind"
fi

if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -sf $(which batcat) ~/.local/bin/bat
    echo "✓ Created 'bat' symlink for batcat"
fi

# Configure tmux defaults
echo ""
echo "[9/14] Configuring tmux defaults..."
TMUX_BLOCK=$(cat << 'EOF'
# >>> zsh_stuff tmux defaults >>>
# Sensible tmux defaults for better scrolling/history/copy behavior.
set -g mouse on
set -g history-limit 100000
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g set-clipboard on
set -g xterm-keys on
set -g status-position top
# Improve Ctrl/Alt key handling in modern terminals.
set -as terminal-features ',*:extkeys'
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Vim-style keys in copy mode.
setw -g mode-keys vi

# Copy-mode bindings:
# - y copies current selection and exits copy mode.
# - Enter copies current selection and exits copy mode.
# Clipboard backend preference: wl-copy (Wayland) -> xclip (X11) -> tmux buffer only.
if-shell 'command -v wl-copy >/dev/null 2>&1' \
  'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"' \
  'if-shell "command -v xclip >/dev/null 2>&1" "bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel \"xclip -in -selection clipboard\"" "bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel"'

if-shell 'command -v wl-copy >/dev/null 2>&1' \
  'bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "wl-copy"' \
  'if-shell "command -v xclip >/dev/null 2>&1" "bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel \"xclip -in -selection clipboard\"" "bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel"'
# <<< zsh_stuff tmux defaults <<<
EOF
)

if [ -f "$TMUX_CONF" ]; then
    if grep -qF "$TMUX_MARKER_BEGIN" "$TMUX_CONF" && grep -qF "$TMUX_MARKER_END" "$TMUX_CONF"; then
        awk -v start="$TMUX_MARKER_BEGIN" -v end="$TMUX_MARKER_END" -v block="$TMUX_BLOCK" '
            $0 == start {
                print block
                in_block=1
                next
            }
            $0 == end {
                in_block=0
                next
            }
            !in_block { print }
        ' "$TMUX_CONF" > "$TMUX_CONF.tmp"
        mv "$TMUX_CONF.tmp" "$TMUX_CONF"
        echo "✓ Updated existing managed tmux config block in $TMUX_CONF"
    else
        {
            echo ""
            echo "$TMUX_BLOCK"
        } >> "$TMUX_CONF"
        echo "✓ Appended tmux defaults block to $TMUX_CONF"
    fi
else
    printf "%s\n" "$TMUX_BLOCK" > "$TMUX_CONF"
    echo "✓ Created $TMUX_CONF with tmux defaults"
fi

# Install Nerd Fonts for Powerlevel10k
echo ""
echo "[10/14] Installing Nerd Fonts (Hack Nerd Font)..."
echo ""
sudo apt-get install -y fonts-powerline wget unzip
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

if [ ! -f "Hack Regular Nerd Font Complete.ttf" ]; then
    echo "Downloading Hack Nerd Font..."
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
    unzip -q -o Hack.zip
    rm -f Hack.zip
    fc-cache -fv > /dev/null 2>&1
    echo "✓ Hack Nerd Font installed"
else
    echo "✓ Hack Nerd Font already installed"
fi
cd ~

# Migrate custom exports from existing ~/.zshrc into ~/.zshrc.local
echo ""
echo "[11/14] Migrating custom content to ~/.zshrc.local..."

if [ -f "$HOME/.zshrc.local" ]; then
    echo "✓ ~/.zshrc.local already exists; leaving it unchanged"
elif [ -f "$HOME/.zshrc" ]; then
    # Extract likely secret exports to a user-managed config file.
    grep -E "^export ([A-Za-z_][A-Za-z0-9_]*_(TOKEN|KEY)|TOKEN|API_KEY|AWS_[A-Za-z0-9_]*|GITHUB_[A-Za-z0-9_]*)=" "$HOME/.zshrc" > "$HOME/.zshrc.local" 2>/dev/null || true

    if [ -s "$HOME/.zshrc.local" ]; then
        echo "✓ Migrated custom exports to ~/.zshrc.local"
        cat "$HOME/.zshrc.local"
    else
        # Create a starter local config when no matching exports were found.
        cat > "$HOME/.zshrc.local" << 'EOF'
# Local customizations - not managed by setup script
# Add your custom exports, tokens, and configurations here

# export GITHUB_TOKEN="ghp_xxxxx"
# export OPENAI_API_KEY="sk-xxxxx"
EOF
        echo "✓ Created ~/.zshrc.local template"
    fi
else
    cat > "$HOME/.zshrc.local" << 'EOF'
# Local customizations - not managed by setup script
# Add your custom exports, tokens, and configurations here

# export GITHUB_TOKEN="ghp_xxxxx"
# export OPENAI_API_KEY="sk-xxxxx"
EOF
    echo "✓ Created ~/.zshrc.local template"
fi

# Create custom .zshrc configuration
echo ""
echo "[12/14] Creating custom .zshrc configuration..."
if [ ! -f "$ZSHRC_TEMPLATE" ]; then
    echo "Error: Missing zshrc template at $ZSHRC_TEMPLATE"
    exit 1
fi

cp "$ZSHRC_TEMPLATE" "$HOME/.zshrc.new"

echo "✓ Created ~/.zshrc.new with custom configuration"

# Backup existing ~/.zshrc and install the new one automatically
echo ""
echo "[13/14] Installing ~/.zshrc (with backup)..."
if [ -f "$HOME/.zshrc" ]; then
    BACKUP_PATH="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP_PATH"
    echo "✓ Backed up existing ~/.zshrc to $BACKUP_PATH"
fi
cp "$HOME/.zshrc.new" "$HOME/.zshrc"
echo "✓ Installed new ~/.zshrc"

# Change default shell to zsh automatically when possible
if command -v chsh &> /dev/null; then
    CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
    ZSH_PATH=$(which zsh)
    if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
        echo ""
        echo "Attempting to set default shell to zsh..."
        if chsh -s "$ZSH_PATH"; then
            echo "✓ Default shell changed to $ZSH_PATH"
        else
            echo "⚠ Could not change default shell automatically."
            echo "  Run this manually: chsh -s $ZSH_PATH"
        fi
    else
        echo "✓ Default shell is already zsh"
    fi
fi

# Add auto-launch zsh to .bashrc
echo ""
echo "[14/14] Configuring .bashrc to auto-launch zsh..."
if ! grep -q "Auto-launch zsh" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Auto-launch zsh if available (added for zsh setup)
if [ -t 1 ] && command -v zsh >/dev/null 2>&1; then
    export SHELL=$(which zsh)
    exec zsh
fi
EOF
    echo "✓ Added zsh auto-launch to .bashrc"
else
    echo "✓ .bashrc already configured for zsh auto-launch"
fi

echo ""
echo "======================================================================"
echo "Installation Complete!"
echo "======================================================================"
echo ""
echo "Everything possible was configured automatically."
echo "Final steps:"
echo ""
echo "1. Close ALL terminal windows and reopen"
echo "   - Terminal should now start in zsh automatically"
echo "   - Powerlevel10k will prompt you to configure (or run: p10k configure)"
echo ""
echo "2. Use ~/.zshrc.local for your personal exports/tokens"
echo "   - This file is never overwritten by the setup script"
if [ -n "${BACKUP_PATH:-}" ]; then
    echo "   - Existing ~/.zshrc backup created at:"
    echo "       $BACKUP_PATH"
    echo "   - If any token exports are missing, copy them from that backup into ~/.zshrc.local"
else
    echo "   - If you had a previous ~/.zshrc, check backups with:"
    echo "       ls -1t ~/.zshrc.backup.*"
fi
echo ""
echo "Documentation: ~/zsh_stuff/ZSH_SETUP_GUIDE.md"
echo "======================================================================"
