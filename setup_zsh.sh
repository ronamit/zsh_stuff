#!/bin/bash
# ======================================================================
# ZSH Setup Script (Linux + macOS)
# ======================================================================
# Installs and configures zsh with Oh My Zsh, Powerlevel10k, and plugins.
# Safe to re-run — skips already-installed components.
# - Linux (Debian/Ubuntu): uses apt.
# - macOS: uses Homebrew (install from https://brew.sh if missing).
#
# Usage:  bash setup_zsh.sh
# ======================================================================

# Fail on undefined variables and pipe errors.
set -uo pipefail

# ── Globals ──────────────────────────────────────────────────────────

TMUX_CONF="$HOME/.tmux.conf"
TMUX_MARKER_BEGIN="# >>> zsh_stuff tmux defaults >>>"
TMUX_MARKER_END="# <<< zsh_stuff tmux defaults <<<"
SSH_CONFIG="$HOME/.ssh/config"
SSH_MARKER_BEGIN="# >>> zsh_stuff ssh keepalive >>>"
SSH_MARKER_END="# <<< zsh_stuff ssh keepalive <<<"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_TEMPLATE="$SCRIPT_DIR/.zshrc.template.sh"
BACKUP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/backups"
STEP=0

# OS detection
if [[ "$(uname -s)" == "Darwin" ]]; then
    IS_MACOS=1
else
    IS_MACOS=0
fi

APT_PACKAGES_TO_INSTALL=()
APT_INDEX_REFRESHED=0

# ── Helpers ──────────────────────────────────────────────────────────

step() { STEP=$((STEP + 1)); echo ""; echo "[$STEP] $1"; }

apt_update_once() {
    if [ "$APT_INDEX_REFRESHED" -eq 0 ]; then
        echo "  Refreshing apt package index..."
        if sudo apt-get update -qq; then
            APT_INDEX_REFRESHED=1
        else
            echo "  ✗ apt-get update failed"
            exit 1
        fi
    fi
}

pkg_is_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

apt_pkg_exists() {
    local pkg="$1"
    if apt-cache show "$pkg" &>/dev/null; then
        return 0
    fi
    if [ "$APT_INDEX_REFRESHED" -eq 0 ]; then
        apt_update_once
        if apt-cache show "$pkg" &>/dev/null; then return 0; fi
    fi
    return 1
}

add_pkg() {
    local pkg="$1"
    [ -z "$pkg" ] && return 0
    pkg_is_installed "$pkg" && return 0
    for existing in "${APT_PACKAGES_TO_INSTALL[@]+"${APT_PACKAGES_TO_INSTALL[@]}"}"; do
        [ "$existing" = "$pkg" ] && return 0
    done
    APT_PACKAGES_TO_INSTALL+=("$pkg")
}

add_pkg_if_missing_cmd() {
    local cmd="$1" pkg="$2"
    command -v "$cmd" &>/dev/null || add_pkg "$pkg"
}

add_best_effort_pkg_if_missing_cmd() {
    local cmd="$1" pkg="$2"
    command -v "$cmd" &>/dev/null && return 0
    pkg_is_installed "$pkg" && return 0
    if apt_pkg_exists "$pkg"; then
        add_pkg "$pkg"
    else
        echo "  - Skipping $pkg (not found in apt)"
    fi
}

add_best_effort_pkg() {
    local pkg="$1"
    pkg_is_installed "$pkg" && return 0
    if apt_pkg_exists "$pkg"; then
        add_pkg "$pkg"
    else
        echo "  - Skipping $pkg (not found in apt)"
    fi
}

install_brew_formula_if_missing() {
    local cmd="$1" formula="$2"
    if command -v "$cmd" &>/dev/null; then
        return 0
    fi
    echo "  Installing Homebrew formula: $formula"
    if brew install "$formula"; then
        return 0
    else
        echo "  ✗ Failed to install Homebrew formula: $formula"
        exit 1
    fi
}

clone_if_missing() {
    local label="$1" url="$2" dir="$3" name="$4"
    step "$label"
    if [ -d "$dir" ]; then
        echo "  ✓ $name already installed"
    else
        if git clone --depth=1 "$url" "$dir"; then
            echo "  ✓ $name installed"
        else
            echo "  ✗ Failed to clone $name from $url"
            exit 1
        fi
    fi
}

has_hack_nerd_font() {
    if command -v fc-list &>/dev/null && fc-list 2>/dev/null | grep -qi 'Hack Nerd Font'; then
        return 0
    fi
    compgen -G "$HOME/.local/share/fonts/Hack*Nerd*Font*.ttf" >/dev/null 2>&1 && return 0
    compgen -G "$HOME/.local/share/fonts/Hack*Nerd*Font*.otf" >/dev/null 2>&1 && return 0
    # macOS Homebrew cask or user fonts
    compgen -G "$HOME/Library/Fonts/Hack*Nerd*Font*.ttf" >/dev/null 2>&1 && return 0
    compgen -G "$HOME/Library/Fonts/Hack*Nerd*Font*.otf" >/dev/null 2>&1 && return 0
    return 1
}

create_zshrc_local_template() {
    cat > "$HOME/.zshrc.local" << 'EOF'
# ~/.zshrc.local — Personal settings (not managed by setup_zsh.sh)
# Add exports, tokens, and machine-specific overrides here.
# Toggle live auto-list while typing (cd/path suggestions):
# export ZSH_AUTOLIST_ON_TYPE=1   # 1=on (default), 0=off
# Auto-open `cd ` list only when local dir count is small:
# export ZSH_AUTOLIST_CD_EMPTY_MAX=20

# export GITHUB_TOKEN="ghp_xxxxx"
# export OPENAI_API_KEY="sk-xxxxx"
# export HF_TOKEN="hf_xxxxx"
EOF
    echo "  ✓ Created ~/.zshrc.local template"
}

# ── Pre-flight ───────────────────────────────────────────────────────

echo "======================================================================"
if [ "$IS_MACOS" -eq 1 ]; then
    echo "ZSH Setup (macOS)"
else
    echo "ZSH Setup (Linux)"
fi
echo "======================================================================"

if [ ! -f "$ZSHRC_TEMPLATE" ]; then
    echo "Error: Missing .zshrc.template.sh at $ZSHRC_TEMPLATE"
    exit 1
fi

if [ "$IS_MACOS" -eq 1 ]; then
    if ! command -v brew &>/dev/null; then
        echo "Error: Homebrew not found. Install from https://brew.sh then re-run."
        exit 1
    fi
else
    if ! command -v apt-get &>/dev/null; then
        echo "Error: apt-get not found. This script supports Ubuntu/Debian or macOS (Homebrew)."
        exit 1
    fi
fi

# ── Bootstrap: zsh, curl, git ────────────────────────────────────────

step "Installing core dependencies (zsh, curl, git)..."
if [ "$IS_MACOS" -eq 1 ]; then
    install_brew_formula_if_missing zsh zsh
    install_brew_formula_if_missing curl curl
    install_brew_formula_if_missing git git
    echo "  ✓ Core tools checked (Homebrew)"
else
BOOTSTRAP=()
command -v zsh  &>/dev/null || BOOTSTRAP+=("zsh")
command -v curl &>/dev/null || BOOTSTRAP+=("curl")
command -v git  &>/dev/null || BOOTSTRAP+=("git")

if [ "${#BOOTSTRAP[@]}" -gt 0 ]; then
    apt_update_once
    if sudo apt-get install -y "${BOOTSTRAP[@]}"; then
        echo "  ✓ Installed: ${BOOTSTRAP[*]}"
    else
        echo "  ✗ Failed to install bootstrap packages: ${BOOTSTRAP[*]}"
        exit 1
    fi
else
    echo "  ✓ zsh, curl, git already present"
fi
fi

# ── Oh My Zsh ────────────────────────────────────────────────────────

step "Installing Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  ✓ Oh My Zsh already installed"
else
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        echo "  ✓ Oh My Zsh installed"
    else
        echo "  ✗ Failed to install Oh My Zsh"
        exit 1
    fi
fi

# ── Plugins & Theme ──────────────────────────────────────────────────

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing "Powerlevel10k theme" \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$ZSH_CUSTOM/themes/powerlevel10k" "Powerlevel10k"

clone_if_missing "zsh-autosuggestions" \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions" "zsh-autosuggestions"

clone_if_missing "zsh-syntax-highlighting" \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting"

clone_if_missing "zsh-history-substring-search" \
    "https://github.com/zsh-users/zsh-history-substring-search.git" \
    "$ZSH_CUSTOM/plugins/zsh-history-substring-search" "zsh-history-substring-search"

clone_if_missing "fzf-tab" \
    "https://github.com/Aloxaf/fzf-tab.git" \
    "$ZSH_CUSTOM/plugins/fzf-tab" "fzf-tab"

# ── APT packages (Linux) ──────────────────────────────────────────────

step "Collecting required/recommended packages..."
if [ "$IS_MACOS" -eq 1 ]; then
    install_brew_formula_if_missing fzf fzf
    install_brew_formula_if_missing tree tree
    install_brew_formula_if_missing tmux tmux
    install_brew_formula_if_missing rg ripgrep
    install_brew_formula_if_missing fd fd
    install_brew_formula_if_missing bat bat
    install_brew_formula_if_missing lsd lsd
    echo "  ✓ Homebrew packages checked"
else
# Core tools
add_pkg_if_missing_cmd wget  wget
add_pkg_if_missing_cmd unzip unzip
add_pkg_if_missing_cmd fc-cache fontconfig

# CLI tools used by aliases/functions
add_pkg_if_missing_cmd fzf  fzf
add_pkg_if_missing_cmd tree tree
add_pkg_if_missing_cmd tmux tmux
add_pkg_if_missing_cmd rg   ripgrep
add_best_effort_pkg_if_missing_cmd lsd lsd

if ! command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    add_pkg "fd-find"
fi
if ! command -v bat &>/dev/null && ! command -v batcat &>/dev/null; then
    add_pkg "bat"
fi

# Port inspection
if ! command -v ss &>/dev/null && ! command -v netstat &>/dev/null; then
    add_best_effort_pkg iproute2
fi

# Python quality-of-life
if ! command -v python &>/dev/null; then
    if apt_pkg_exists python-is-python3; then
        add_pkg "python-is-python3"
    else
        add_best_effort_pkg python3
    fi
fi
add_best_effort_pkg_if_missing_cmd pip3 python3-pip
add_best_effort_pkg python3-venv

# Archive helpers for extract()
add_best_effort_pkg_if_missing_cmd 7z p7zip-full
if ! command -v unrar &>/dev/null; then
    if apt_pkg_exists unrar; then
        add_pkg "unrar"
    elif apt_pkg_exists unrar-free; then
        add_pkg "unrar-free"
    fi
fi

# Oh My Zsh command-not-found backend
add_best_effort_pkg_if_missing_cmd command-not-found command-not-found

# Optional enhancements
add_best_effort_pkg fonts-powerline
add_best_effort_pkg_if_missing_cmd eza eza
if ! command -v delta &>/dev/null; then
    add_best_effort_pkg git-delta
fi

# Clipboard for tmux copy-mode
if ! command -v xclip &>/dev/null && ! command -v wl-copy &>/dev/null; then
    add_best_effort_pkg xclip
    add_best_effort_pkg wl-clipboard
fi

if [ "${#APT_PACKAGES_TO_INSTALL[@]}" -gt 0 ]; then
    echo "  Installing: ${APT_PACKAGES_TO_INSTALL[*]}"
    apt_update_once
    if sudo apt-get install -y "${APT_PACKAGES_TO_INSTALL[@]}"; then
        echo "  ✓ Packages installed"
    else
        echo "  ✗ Failed to install one or more packages"
        exit 1
    fi
else
    echo "  ✓ All packages already present"
fi
fi

# ── Ubuntu tool-name symlinks (Linux only) ────────────────────────────

if [ "$IS_MACOS" -eq 0 ]; then
mkdir -p "$HOME/.local/bin"
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    echo "  ✓ Symlinked fd → fdfind"
fi
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    echo "  ✓ Symlinked bat → batcat"
fi
fi

# ── Tmux defaults ────────────────────────────────────────────────────

step "Configuring tmux defaults..."
TMUX_BLOCK=$(cat << 'EOF'
# >>> zsh_stuff tmux defaults >>>
set -g mouse on
set -g history-limit 100000
set -g default-terminal "tmux-256color"
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g set-clipboard on
set -gq allow-passthrough on
set -g xterm-keys on
set -g status-position top
set -as terminal-features ',*:RGB'
set -as terminal-features ',*:extkeys'
set -as terminal-features ',*:hyperlinks'
set -ga terminal-overrides ',*:Tc'
bind r source-file ~/.tmux.conf

# Vim copy-mode
setw -g mode-keys vi

# Clipboard: wl-copy (Wayland) → xclip (X11) → tmux buffer
# Safe default when no external clipboard helper exists.
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel

if-shell 'command -v wl-copy >/dev/null 2>&1' \
  'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel wl-copy'
if-shell 'command -v wl-copy >/dev/null 2>&1' \
  'bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel wl-copy'
if-shell 'command -v wl-copy >/dev/null 2>&1' \
  'bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel wl-copy'
if-shell '! command -v wl-copy >/dev/null 2>&1 && command -v xclip >/dev/null 2>&1' \
  'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"'
if-shell '! command -v wl-copy >/dev/null 2>&1 && command -v xclip >/dev/null 2>&1' \
  'bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"'
if-shell '! command -v wl-copy >/dev/null 2>&1 && command -v xclip >/dev/null 2>&1' \
  'bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"'
# <<< zsh_stuff tmux defaults <<<
EOF
)

if [ -f "$TMUX_CONF" ]; then
    if grep -qF "$TMUX_MARKER_BEGIN" "$TMUX_CONF" && grep -qF "$TMUX_MARKER_END" "$TMUX_CONF"; then
        awk -v start="$TMUX_MARKER_BEGIN" -v end="$TMUX_MARKER_END" -v block="$TMUX_BLOCK" '
            $0 == start { print block; in_block=1; next }
            $0 == end   { in_block=0; next }
            !in_block   { print }
        ' "$TMUX_CONF" > "$TMUX_CONF.tmp"
        mv "$TMUX_CONF.tmp" "$TMUX_CONF"
        echo "  ✓ Updated managed tmux block"
    else
        printf "\n%s\n" "$TMUX_BLOCK" >> "$TMUX_CONF"
        echo "  ✓ Appended tmux block to $TMUX_CONF"
    fi
else
    printf "%s\n" "$TMUX_BLOCK" > "$TMUX_CONF"
    echo "  ✓ Created $TMUX_CONF"
fi

# ── SSH keepalive defaults ───────────────────────────────────────────

step "Configuring SSH keepalive defaults..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh" 2>/dev/null || true

SSH_BLOCK=$(cat << 'EOF'
# >>> zsh_stuff ssh keepalive >>>
Host *
    ServerAliveInterval 30
    ServerAliveCountMax 3
    TCPKeepAlive yes
# <<< zsh_stuff ssh keepalive <<<
EOF
)

if [ -f "$SSH_CONFIG" ]; then
    if grep -qF "$SSH_MARKER_BEGIN" "$SSH_CONFIG" && grep -qF "$SSH_MARKER_END" "$SSH_CONFIG"; then
        awk -v start="$SSH_MARKER_BEGIN" -v end="$SSH_MARKER_END" -v block="$SSH_BLOCK" '
            $0 == start { print block; in_block=1; next }
            $0 == end   { in_block=0; next }
            !in_block   { print }
        ' "$SSH_CONFIG" > "$SSH_CONFIG.tmp"
        mv "$SSH_CONFIG.tmp" "$SSH_CONFIG"
        echo "  ✓ Updated managed SSH keepalive block"
    else
        printf "\n%s\n" "$SSH_BLOCK" >> "$SSH_CONFIG"
        echo "  ✓ Appended SSH keepalive block to $SSH_CONFIG"
    fi
else
    printf "%s\n" "$SSH_BLOCK" > "$SSH_CONFIG"
    echo "  ✓ Created $SSH_CONFIG"
fi
chmod 600 "$SSH_CONFIG" 2>/dev/null || true

# ── Hack Nerd Font ───────────────────────────────────────────────────

step "Installing Hack Nerd Font..."
if [ "$IS_MACOS" -eq 1 ]; then
    mkdir -p "$HOME/Library/Fonts"
    if ! has_hack_nerd_font; then
        echo "  Installing via Homebrew..."
        if brew install --cask font-hack-nerd-font 2>/dev/null; then
            echo "  ✓ Hack Nerd Font installed"
        else
            echo "  Downloading Hack Nerd Font..."
            FONT_ZIP="${TMPDIR:-/tmp}/Hack.zip"
            if curl -sL -o "$FONT_ZIP" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"; then
                unzip -q -o "$FONT_ZIP" -d "$HOME/Library/Fonts"
                rm -f "$FONT_ZIP"
                echo "  ✓ Hack Nerd Font installed"
            else
                rm -f "$FONT_ZIP"
                echo "  ⚠ Font download failed — install manually: brew install --cask font-hack-nerd-font"
            fi
        fi
    else
        echo "  ✓ Hack Nerd Font already installed"
    fi
else
mkdir -p "$HOME/.local/share/fonts"

if ! has_hack_nerd_font; then
    echo "  Downloading Hack Nerd Font..."
    FONT_ZIP="$HOME/.local/share/fonts/Hack.zip"
    if wget -q --tries=3 --timeout=30 -O "$FONT_ZIP" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip; then
        unzip -q -o "$FONT_ZIP" -d "$HOME/.local/share/fonts"
        rm -f "$FONT_ZIP"
        fc-cache -f >/dev/null 2>&1
        echo "  ✓ Hack Nerd Font installed"
    else
        rm -f "$FONT_ZIP"
        echo "  ⚠ Font download failed — install manually later"
    fi
else
    echo "  ✓ Hack Nerd Font already installed"
fi
fi

# ── Migrate exports → ~/.zshrc.local ────────────────────────────────

step "Setting up ~/.zshrc.local..."

if [ -f "$HOME/.zshrc.local" ]; then
    echo "  ✓ ~/.zshrc.local already exists (not touched)"
elif [ -f "$HOME/.zshrc" ]; then
    # Broad pattern: any export whose name contains TOKEN, KEY, SECRET, or starts with AWS_/HF_/GITHUB_/WANDB_
    grep -E '^export +([A-Za-z_][A-Za-z0-9_]*(TOKEN|KEY|SECRET)[A-Za-z0-9_]*|AWS_[A-Za-z0-9_]*|HF_[A-Za-z0-9_]*|GITHUB_[A-Za-z0-9_]*|WANDB_[A-Za-z0-9_]*)=' \
        "$HOME/.zshrc" > "$HOME/.zshrc.local" 2>/dev/null || true

    if [ -s "$HOME/.zshrc.local" ]; then
        echo "  ✓ Migrated exports to ~/.zshrc.local (values redacted):"
        awk -F= '{print "    " $1 "=<redacted>"}' "$HOME/.zshrc.local"
    else
        create_zshrc_local_template
    fi
else
    create_zshrc_local_template
fi

# ── Install ~/.zshrc ─────────────────────────────────────────────────

step "Installing ~/.zshrc from template..."
BACKUP_PATH=""
if [ -f "$HOME/.zshrc" ]; then
    if mkdir -p "$BACKUP_DIR"; then
        BACKUP_PATH="$BACKUP_DIR/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    else
        echo "  ✗ Failed to create backup directory: $BACKUP_DIR"
        exit 1
    fi
    if cp "$HOME/.zshrc" "$BACKUP_PATH"; then
        echo "  ✓ Backup → $BACKUP_PATH"
    else
        echo "  ✗ Failed to back up ~/.zshrc"
        exit 1
    fi
fi
if cp "$ZSHRC_TEMPLATE" "$HOME/.zshrc"; then
    echo "  ✓ Installed ~/.zshrc"
else
    echo "  ✗ Failed to install ~/.zshrc from template"
    exit 1
fi

# ── Git aliases (for muscle memory / faster branch switching) ─────────

step "Ensuring git switch aliases..."
if command -v git &>/dev/null; then
    git config --global alias.sw switch
    git config --global alias.swc 'switch --create'
    echo "  ✓ Set git aliases: sw, swc"
else
    echo "  ⚠ git not found; skipped git alias setup"
fi

# ── ~/.zshenv (skip_global_compinit) ─────────────────────────────────

step "Ensuring ~/.zshenv compatibility..."
ZSHENV_LINE="skip_global_compinit=1"
if [ -f "$HOME/.zshenv" ]; then
    if grep -q "^${ZSHENV_LINE}$" "$HOME/.zshenv"; then
        echo "  ✓ ~/.zshenv already has $ZSHENV_LINE"
    else
        { echo "# zsh completion: avoid global compinit conflicts."; echo "$ZSHENV_LINE"; echo ""; cat "$HOME/.zshenv"; } > "$HOME/.zshenv.tmp"
        mv "$HOME/.zshenv.tmp" "$HOME/.zshenv"
        echo "  ✓ Added $ZSHENV_LINE to ~/.zshenv"
    fi
else
    printf "# zsh completion: avoid global compinit conflicts.\n%s\n" "$ZSHENV_LINE" > "$HOME/.zshenv"
    echo "  ✓ Created ~/.zshenv"
fi

# ── Default shell → zsh ─────────────────────────────────────────────

step "Setting default shell to zsh..."
if command -v chsh &>/dev/null; then
    if [ "$IS_MACOS" -eq 1 ]; then
        CURRENT_SHELL=$(dscl . -read "/Users/${USER:-$(whoami)}" UserShell 2>/dev/null | awk '{print $2}')
    else
        CURRENT_SHELL=$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)
    fi
    ZSH_PATH=$(command -v zsh)
    if [ -z "$CURRENT_SHELL" ] || [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
        if chsh -s "$ZSH_PATH" 2>/dev/null; then
            echo "  ✓ Default shell → $ZSH_PATH"
        else
            echo "  ⚠ chsh failed — run manually: chsh -s $ZSH_PATH"
        fi
    else
        echo "  ✓ Default shell is already zsh"
    fi
else
    echo "  ⚠ chsh not available"
fi

# ── .bashrc fallback auto-launch ────────────────────────────────────

step "Adding .bashrc zsh auto-launch fallback..."
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ] && ! grep -q "Auto-launch zsh" "$BASHRC"; then
    cat >> "$BASHRC" << 'EOF'

# Auto-launch zsh if available (added by zsh_stuff setup)
if [ -t 1 ] && [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null 2>&1; then
    export SHELL=$(command -v zsh)
    exec zsh
fi
EOF
    echo "  ✓ Added zsh auto-launch to .bashrc"
else
    echo "  ✓ .bashrc already configured"
fi

# ── Done ─────────────────────────────────────────────────────────────

echo ""
echo "======================================================================"
echo "✓ Setup complete!"
echo "======================================================================"
echo ""
echo "Next steps:"
echo ""
echo "  1. Add personal exports/tokens to ~/.zshrc.local"
if [ -n "$BACKUP_PATH" ]; then
    echo "     Previous config backed up to: $BACKUP_PATH"
fi
echo ""
echo "  2. Start a new terminal (or run: exec zsh)"
echo ""
echo "  3. Set your terminal font to 'Hack Nerd Font'"
echo ""
echo "  4. Optional: run 'p10k configure' to customize prompt"
echo ""
echo "Docs: $SCRIPT_DIR/ZSH_SETUP_GUIDE.md"
echo "======================================================================"
