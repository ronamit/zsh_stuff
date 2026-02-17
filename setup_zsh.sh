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
APT_PACKAGES_TO_INSTALL=()

apt_pkg_exists() {
    apt-cache show "$1" &> /dev/null
}

add_pkg() {
    local pkg="$1"
    local existing
    [ -z "$pkg" ] && return
    for existing in "${APT_PACKAGES_TO_INSTALL[@]}"; do
        [ "$existing" = "$pkg" ] && return
    done
    APT_PACKAGES_TO_INSTALL+=("$pkg")
}

add_pkg_if_missing_cmd() {
    local cmd="$1"
    local pkg="$2"
    if ! command -v "$cmd" &> /dev/null; then
        add_pkg "$pkg"
    fi
}

add_best_effort_pkg_if_missing_cmd() {
    local cmd="$1"
    local pkg="$2"
    if command -v "$cmd" &> /dev/null; then
        return
    fi
    if apt_pkg_exists "$pkg"; then
        add_pkg "$pkg"
    else
        echo "- Skipping $pkg (package not found in current apt repositories)"
    fi
}

add_best_effort_pkg() {
    local pkg="$1"
    if apt_pkg_exists "$pkg"; then
        add_pkg "$pkg"
    else
        echo "- Skipping $pkg (package not found in current apt repositories)"
    fi
}

install_git_repo_if_missing() {
    local step_label="$1"
    local repo_url="$2"
    local target_dir="$3"
    local display_name="$4"

    echo ""
    echo "$step_label"
    if [ ! -d "$target_dir" ]; then
        git clone --depth=1 "$repo_url" "$target_dir"
        echo "✓ $display_name installed successfully"
    else
        echo "✓ $display_name is already installed"
    fi
}

create_zshrc_local_template() {
    cat > "$HOME/.zshrc.local" << 'EOF'
# Local customizations - not managed by setup script
# Add your custom exports, tokens, and configurations here

# export GITHUB_TOKEN="ghp_xxxxx"
# export OPENAI_API_KEY="sk-xxxxx"
EOF
    echo "✓ Created ~/.zshrc.local template"
}

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

# Bootstrap dependencies needed before remote installers/clones.
BOOTSTRAP_PACKAGES=()
if ! command -v curl &> /dev/null; then
    BOOTSTRAP_PACKAGES+=("curl")
fi
if ! command -v git &> /dev/null; then
    BOOTSTRAP_PACKAGES+=("git")
fi
if [ "${#BOOTSTRAP_PACKAGES[@]}" -gt 0 ]; then
    echo ""
    echo "Installing bootstrap dependencies: ${BOOTSTRAP_PACKAGES[*]}"
    sudo apt-get install -y "${BOOTSTRAP_PACKAGES[@]}"
    echo "✓ Bootstrap dependencies installed"
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
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
install_git_repo_if_missing \
    "[4/14] Installing Powerlevel10k theme..." \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$P10K_DIR" \
    "Powerlevel10k"

# Install zsh-autosuggestions
AUTOSUGGEST_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
install_git_repo_if_missing \
    "[5/14] Installing zsh-autosuggestions plugin..." \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$AUTOSUGGEST_DIR" \
    "zsh-autosuggestions"

# Install zsh-syntax-highlighting
SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
install_git_repo_if_missing \
    "[6/14] Installing zsh-syntax-highlighting plugin..." \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$SYNTAX_DIR" \
    "zsh-syntax-highlighting"

# Install zsh-history-substring-search
HISTORY_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"
install_git_repo_if_missing \
    "[7/14] Installing zsh-history-substring-search plugin..." \
    "https://github.com/zsh-users/zsh-history-substring-search.git" \
    "$HISTORY_DIR" \
    "zsh-history-substring-search"

# Install required/recommended packages
echo ""
echo "[8/14] Installing required/recommended packages..."

# Core dependencies used directly by this setup script and zshrc template.
add_pkg_if_missing_cmd git git
add_pkg_if_missing_cmd curl curl
add_pkg_if_missing_cmd wget wget
add_pkg_if_missing_cmd unzip unzip
add_pkg_if_missing_cmd fc-cache fontconfig
add_pkg_if_missing_cmd xdg-open xdg-utils

# CLI tools used by aliases/functions.
add_pkg_if_missing_cmd fzf fzf
if ! command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    add_pkg "fd-find"
fi
if ! command -v bat &> /dev/null && ! command -v batcat &> /dev/null; then
    add_pkg "bat"
fi
add_pkg_if_missing_cmd tree tree
add_pkg_if_missing_cmd tmux tmux
add_pkg_if_missing_cmd rg ripgrep

# Ensure one port-inspection backend for `ports()`.
if ! command -v ss &> /dev/null && ! command -v netstat &> /dev/null; then
    add_best_effort_pkg iproute2
    add_best_effort_pkg net-tools
fi

# Python quality-of-life for venv aliases and `python` command.
if ! command -v python &> /dev/null; then
    if apt_pkg_exists python-is-python3; then
        add_pkg "python-is-python3"
    else
        add_best_effort_pkg python3
    fi
fi
add_best_effort_pkg_if_missing_cmd pip3 python3-pip
add_best_effort_pkg python3-venv

# Archive helpers used by extract().
add_best_effort_pkg_if_missing_cmd 7z p7zip-full
if ! command -v unrar &> /dev/null; then
    if apt_pkg_exists unrar; then
        add_pkg "unrar"
    elif apt_pkg_exists unrar-free; then
        add_pkg "unrar-free"
    else
        echo "- Skipping unrar/unrar-free (package not found in current apt repositories)"
    fi
fi
add_best_effort_pkg_if_missing_cmd uncompress ncompress

# Oh My Zsh command-not-found plugin backend.
add_best_effort_pkg_if_missing_cmd command-not-found command-not-found

# Powerlevel10k + font install prerequisites.
add_best_effort_pkg fonts-powerline

# Optional enhancements.
add_best_effort_pkg_if_missing_cmd eza eza
if ! command -v delta &> /dev/null; then
    add_best_effort_pkg git-delta
fi

# Clipboard tools for tmux copy-mode integration.
if ! command -v xclip &> /dev/null && ! command -v wl-copy &> /dev/null; then
    add_best_effort_pkg xclip
    add_best_effort_pkg wl-clipboard
fi

if [ "${#APT_PACKAGES_TO_INSTALL[@]}" -gt 0 ]; then
    echo ""
    echo "Installing packages: ${APT_PACKAGES_TO_INSTALL[*]}"
    sudo apt-get install -y "${APT_PACKAGES_TO_INSTALL[@]}"
    echo "✓ Required/recommended packages installed"
else
    echo "✓ All required/recommended packages are already installed"
fi

# Create symlinks for Ubuntu-specific tool names
mkdir -p "$HOME/.local/bin"
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    echo "✓ Created 'fd' symlink for fdfind"
fi

if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
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
mkdir -p "$HOME/.local/share/fonts"

if [ ! -f "$HOME/.local/share/fonts/Hack Regular Nerd Font Complete.ttf" ]; then
    (
        cd "$HOME/.local/share/fonts"
        echo "Downloading Hack Nerd Font..."
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
        unzip -q -o Hack.zip
        rm -f Hack.zip
    )
    fc-cache -fv > /dev/null 2>&1
    echo "✓ Hack Nerd Font installed"
else
    echo "✓ Hack Nerd Font already installed"
fi

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
        create_zshrc_local_template
    fi
else
    create_zshrc_local_template
fi

# Validate zshrc template
echo ""
echo "[12/14] Validating zshrc template..."
if [ ! -f "$ZSHRC_TEMPLATE" ]; then
    echo "Error: Missing zshrc template at $ZSHRC_TEMPLATE"
    exit 1
fi
echo "✓ Using template at $ZSHRC_TEMPLATE"

# Backup existing ~/.zshrc and install the new one automatically
echo ""
echo "[13/14] Installing ~/.zshrc (with backup)..."
if [ -f "$HOME/.zshrc" ]; then
    BACKUP_PATH="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP_PATH"
    echo "✓ Backed up existing ~/.zshrc to $BACKUP_PATH"
fi
cp "$ZSHRC_TEMPLATE" "$HOME/.zshrc"
echo "✓ Installed ~/.zshrc from template"

# Change default shell to zsh automatically when possible
if command -v chsh &> /dev/null; then
    CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
    ZSH_PATH=$(command -v zsh)
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
    export SHELL=$(command -v zsh)
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
echo "1. Copy personal exports/tokens into ~/.zshrc.local first"
echo "   - This file is never overwritten by the setup script"
if [ -n "${BACKUP_PATH:-}" ]; then
    echo "   - Existing ~/.zshrc backup:"
    echo "       $BACKUP_PATH"
    echo "   - If any token exports are missing, copy them from that backup into ~/.zshrc.local"
else
    echo "   - If you had a previous ~/.zshrc, check backups with:"
    echo "       ls -1t ~/.zshrc.backup.*"
fi
echo ""
echo "2. Apply the new zsh config"
echo "   - Option A: Start a new terminal session"
echo "   - Option B: Run: source ~/.zshrc"
echo "   - Then run: p10k configure (optional)"
echo ""
echo "Documentation: ~/zsh_stuff/ZSH_SETUP_GUIDE.md"
echo "======================================================================"
