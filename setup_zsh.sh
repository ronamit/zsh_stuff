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

# Check if running on Ubuntu/Debian
if ! command -v apt-get &> /dev/null; then
    echo "Error: This script is designed for Ubuntu/Debian systems"
    exit 1
fi

# Update package lists
echo ""
echo "[1/13] Updating package lists..."
echo ""
sudo apt-get update

# Install zsh
echo ""
echo "[2/13] Installing zsh..."
if ! command -v zsh &> /dev/null; then
    echo ""
    sudo apt-get install -y zsh
    echo "✓ zsh installed successfully"
else
    echo "✓ zsh is already installed"
fi

# Install Oh My Zsh
echo ""
echo "[3/13] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed successfully"
else
    echo "✓ Oh My Zsh is already installed"
fi

# Install Powerlevel10k theme
echo ""
echo "[4/13] Installing Powerlevel10k theme..."
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    echo "✓ Powerlevel10k installed successfully"
else
    echo "✓ Powerlevel10k is already installed"
fi

# Install zsh-autosuggestions
echo ""
echo "[5/13] Installing zsh-autosuggestions plugin..."
AUTOSUGGEST_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$AUTOSUGGEST_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGEST_DIR"
    echo "✓ zsh-autosuggestions installed successfully"
else
    echo "✓ zsh-autosuggestions is already installed"
fi

# Install zsh-syntax-highlighting
echo ""
echo "[6/13] Installing zsh-syntax-highlighting plugin..."
SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$SYNTAX_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_DIR"
    echo "✓ zsh-syntax-highlighting installed successfully"
else
    echo "✓ zsh-syntax-highlighting is already installed"
fi

# Install zsh-history-substring-search
echo ""
echo "[7/13] Installing zsh-history-substring-search plugin..."
HISTORY_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"
if [ ! -d "$HISTORY_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search "$HISTORY_DIR"
    echo "✓ zsh-history-substring-search installed successfully"
else
    echo "✓ zsh-history-substring-search is already installed"
fi

# Install recommended tools
echo ""
echo "[8/13] Installing recommended tools..."
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
echo "[9/13] Configuring tmux defaults..."
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
# Improve Ctrl/Alt key handling in modern terminals.
set -as terminal-features ',*:extkeys'

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
echo "[10/13] Installing Nerd Fonts (Hack Nerd Font)..."
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

# Create custom .zshrc configuration
echo ""
echo "[11/13] Creating custom .zshrc configuration..."
cat > ~/.zshrc.new << 'EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# COMPLETION_WAITING_DOTS="true"
# COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    colored-man-pages
    command-not-found
    extract
    z
    fzf
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Custom URL Highlighting
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 1. Enable syntax highlighters
# Keep `main` for command coloring, and add `pattern` for URL highlighting.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main pattern)

# 2. Define patterns for http and https URLs (Cyan color + Underline)
typeset -A ZSH_HIGHLIGHT_PATTERNS
ZSH_HIGHLIGHT_PATTERNS+=('http://*' 'fg=cyan,underline')
ZSH_HIGHLIGHT_PATTERNS+=('https://*' 'fg=cyan,underline')
ZSH_HIGHLIGHT_PATTERNS+=('www.*' 'fg=cyan,underline')

source $ZSH/oh-my-zsh.sh

# Fallback: ensure syntax-highlighting is loaded even if plugin loading is skipped.
if (( ! $+functions[_zsh_highlight] )); then
  source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Make command syntax colors explicit (useful when terminal/theme colors are subtle).
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='nano'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# ======================================================================
# CUSTOM CONFIGURATION
# ======================================================================

# Add ~/.local/bin to PATH if it exists
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Keep ~/bin support for older personal helper scripts.
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

# ======================================================================
# Backward-Compatibility Shortcuts
# ======================================================================

# Preserve legacy shortcuts from previous zsh configs.
alias cls='clear'
alias h='history'
alias d='dirs -v'
alias path='echo $PATH | tr ":" "\n"'
alias safe_v='v'
alias fix='inv isort && inv formatter --fix && inv lint'
alias ssha='ssh-add'
alias ssha-default='ssh-add ~/.ssh/id_rsa'

if command -v cursor &> /dev/null; then
    alias c='cursor'
elif command -v code &> /dev/null; then
    alias c='code'
fi

# Convenience wrappers for local VPN helper scripts.
[[ -x "$HOME/vpn/vpn-connect.sh" ]] && alias vpn-connect='bash ~/vpn/vpn-connect.sh'
[[ -x "$HOME/vpn/vpn-disconnect.sh" ]] && alias vpn-disconnect='bash ~/vpn/vpn-disconnect.sh'
[[ -x "$HOME/vpn/vpn-status.sh" ]] && alias vpn-status='bash ~/vpn/vpn-status.sh'

# ======================================================================
# Enhanced Aliases
# ======================================================================

# Directory navigation
alias cc='clear'     # Clear screen quickly
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# List directory contents
alias l='ls -lFh'     # size, show type, human readable
alias la='ls -lAFh'   # long list, show almost all, show type, human readable
alias lr='ls -tRFh'   # sorted by date, recursive, show type, human readable
alias lt='tree -L 2'  # tree view (2 levels deep)
alias ldot='ls -ld .*' # show only dotfiles
alias ll='ls -lAh --group-directories-first --color=auto'

# Use bat if available (better cat with syntax highlighting)
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias catt='bat' # Original bat with paging
elif command -v batcat &> /dev/null; then
    alias cat='batcat --paging=never'
    alias catt='batcat'
fi

# File operations
alias cp='cp -iv'     # Confirm before overwriting, verbose
alias mv='mv -iv'     # Confirm before overwriting, verbose
alias rm='rm -iv'     # Confirm before deleting, verbose
alias mkdir='mkdir -pv' # Create parent directories as needed, verbose

# Grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# System
alias df='df -h'      # Human-readable sizes
alias du='du -h'      # Human-readable sizes
alias free='free -h'  # Human-readable sizes
alias ports='netstat -tulanp' # Show open ports
alias myip='curl -s ifconfig.me' # Get external IP
alias localip='hostname -I | awk "{print \$1}"' # Get local IP

# File manager
alias f='xdg-open .'  # Open current directory in file manager

# Safety nets
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# ======================================================================
# Git Shortcuts (Oh My Zsh git plugin provides many, here are extras)
# ======================================================================

alias gst='git status'
alias gaa='git add --all'
alias gcmsg='git commit -m'
alias gl='git pull'
alias gp='git push'
alias gco='git checkout'
alias glog='git log --oneline --decorate --graph'
alias glp='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Go to git root directory
alias cdg='cd $(git rev-parse --show-toplevel 2>/dev/null || pwd)'

# Interactive branch switcher with fzf
if command -v fzf &> /dev/null; then
    alias gbr='git branch | fzf | xargs git checkout'
fi

# Delete current branch and return to main/master
branch_bye() {
    local current_branch=$(git symbolic-ref --short HEAD)
    local main_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    [ -z "$main_branch" ] && main_branch="main"
    git checkout $main_branch && git branch -D $current_branch
}

# Open PR page in browser
# Open PR / MR page in browser (GitHub + GitLab support)
pr() {
    local remote_url
    remote_url=$(git config --get remote.origin.url)

    if [ -z "$remote_url" ]; then
        echo "No remote.origin.url found"
        return 1
    fi

    # Normalize SSH → HTTPS
    local repo_url
    repo_url=$(echo "$remote_url" \
        | sed -e 's/\.git$//' \
              -e 's|git@|https://|' \
              -e 's|:|/|')

    local branch
    branch=$(git symbolic-ref --short HEAD)

    if echo "$repo_url" | grep -qi "gitlab"; then
        # If glab exists, use it (cleanest solution)
        if command -v glab >/dev/null 2>&1; then
            glab mr create --web
        else
            xdg-open "${repo_url}/-/merge_requests/new?merge_request[source_branch]=${branch}" 2>/dev/null
        fi
    else
        # Default to GitHub-style PR
        xdg-open "${repo_url}/pull/new/${branch}" 2>/dev/null
    fi
}


# ======================================================================
# Python Development
# ======================================================================

# Activate virtualenv in current directory
alias v='source .venv/bin/activate 2>/dev/null || source venv/bin/activate 2>/dev/null || echo "No .venv or venv found"'

# Python aliases
alias pyrun='python -m'
alias pyserver='python -m http.server'

# Poetry shortcuts
alias psync='poetry install --sync'
alias plock='poetry lock && poetry install'

# Smart virtualenv auto-activation
autoload -Uz add-zsh-hook
_venv_auto_activate() {
    if [[ -z "$VIRTUAL_ENV" ]]; then
        if [[ -d .venv ]]; then
            source .venv/bin/activate 2>/dev/null
        elif [[ -d venv ]]; then
            source venv/bin/activate 2>/dev/null
        fi
    else
        # Check if we've left the directory with the venv
        local venv_dir="${VIRTUAL_ENV%/*}"
        if [[ "$PWD" != "$venv_dir"* ]]; then
            deactivate 2>/dev/null
        fi
    fi
}
add-zsh-hook chpwd _venv_auto_activate

# ======================================================================
# FZF Configuration
# ======================================================================

if command -v fzf &> /dev/null; then
    # Use fd instead of find if available
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    elif command -v fdfind &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
    fi

    # Better color scheme
    export FZF_DEFAULT_OPTS='
        --height 40%
        --layout=reverse
        --border
        --inline-info
        --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
        --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
        --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
        --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
    '

    # Preview with bat if available
    if command -v bat &> /dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
    elif command -v batcat &> /dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --line-range :500 {}'"
    fi
fi

# ======================================================================
# Custom Functions
# ======================================================================

# Find files by name
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Find text in files
ftext() {
    grep -rnw . -e "$1" 2>/dev/null
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Create or attach to a tmux session.
# Usage:
#   tm        -> attach/create "main"
#   tm 0      -> attach/create session "0"
#   tm mydev  -> attach/create session "mydev"
tm() {
    local session="${1:-main}"
    tmux new -A -s "$session"
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Show disk usage of directories in current location
ducks() {
    du -cks * | sort -rn | head -11
}

# Quick reload of zsh config
alias reload='source ~/.zshrc && echo "✓ zsh config reloaded"'

# ======================================================================
# Zsh-specific configurations
# ======================================================================

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.

# Autosuggestion configuration
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

# History substring search: bind terminfo keys first for tmux/terminal compatibility.
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# Best-practice autosuggestion/completion behavior:
# - Tab keeps completion menu.
# - Right Arrow uses `forward-char` (accepts suggestion at end of line).
# - End uses `end-of-line` (accepts suggestion at end of line).
bindkey '^I' expand-or-complete
bindkey '^ ' autosuggest-accept        # Ctrl+Space
bindkey '^@' autosuggest-accept        # Ctrl+Space in tmux/some terminals
bindkey '^[[C' forward-char            # Right Arrow
bindkey '^[OC' forward-char            # Right Arrow (application mode)
bindkey '^[[F' end-of-line             # End
bindkey '^[OF' end-of-line             # End (application mode)
# bindkey '^[[B' autosuggest-accept    # Down Arrow (optional, overrides history search)

# ======================================================================
# Pyenv configuration (if installed)
# ======================================================================

if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# ======================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# ======================================================================

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "✓ Created ~/.zshrc.new with custom configuration"

# Backup existing ~/.zshrc and install the new one automatically
echo ""
echo "[12/13] Installing ~/.zshrc (with backup)..."
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
echo "[13/13] Configuring .bashrc to auto-launch zsh..."
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
echo "Manual steps (if needed):"
echo ""
echo "1. Configure Terminal to use Hack Nerd Font:"
echo "   - Open Terminal → Edit → Preferences → Profiles → Text"
echo "   - Enable 'Custom font'"
echo "   - Select 'Hack Nerd Font' or 'Hack Regular Nerd Font Complete' with size 11 or 12"
echo ""
echo "2. Close ALL terminal windows and reopen"
echo "   - Terminal should now start in zsh automatically"
echo "   - Powerlevel10k will prompt you to configure (or run: p10k configure)"
echo ""
echo "Tmux quick start:"
echo "  - Create or attach to a named session:"
echo "      tmux new -A -s session_name"
echo "  - List sessions:"
echo "      tmux ls"
echo "  - Kill a session from outside:"
echo "      tmux kill-session -t session_name"
echo "  - Kill current session from inside tmux:"
echo "      tmux kill-session"
echo "  - Reload tmux config:"
echo "      tmux source-file ~/.tmux.conf"
echo ""
echo "Copy tip (iTerm2): hold Option while dragging to select/copy text."
echo ""
echo "Optional tools you can install manually:"
echo "  - micro (text editor): sudo apt-get install micro"
echo "  - pyenv: curl https://pyenv.run | bash"
echo ""
echo "Documentation: ~/zsh_stuff/ZSH_SETUP_GUIDE.md"
echo "======================================================================"
