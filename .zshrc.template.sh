# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My Zsh core ───────────────────────────────────────────────────

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Some IDE terminals start with TERM=dumb, which disables prompt/command colors.
if [[ -o interactive && -t 1 && "$TERM" == "dumb" ]]; then
    export TERM=xterm-256color
fi

HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13
HIST_STAMPS="yyyy-mm-dd"

# ── Plugin detection & compatibility ─────────────────────────────────

_fzf_tab_plugin="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh"
_zsh_highlight_plugin="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
typeset -gi _fzf_tab_loaded=0
[[ -r "$_fzf_tab_plugin" ]] && _fzf_tab_loaded=1
typeset -gi _lsd_installed=0
command -v lsd &>/dev/null && _lsd_installed=1
typeset -gi _zsh_syntax_highlighting_enabled=1

plugins=(
    git
    colored-man-pages
    command-not-found
    extract
    z
    fzf
    zsh-autosuggestions
    zsh-history-substring-search
)

# Load complist (provides menu-select widget for navigable completion menus).
zmodload -i zsh/complist

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# fzf-tab gives interactive fuzzy completion without zsh-autocomplete's
# async completion pipeline, which can hang on heavy git completions.
if (( _fzf_tab_loaded )); then
    source "$_fzf_tab_plugin"
    zstyle ':fzf-tab:*' fzf-flags '--height=40% --layout=reverse --border'
    zstyle ':fzf-tab:*' switch-group ',' '.'
fi

# ══════════════════════════════════════════════════════════════════════
# Everything below runs AFTER oh-my-zsh so our settings are not
# overridden. This is critical for completion styling to work.
# ══════════════════════════════════════════════════════════════════════

# ── Completion styling ───────────────────────────────────────────────

# Re-apply menu select after oh-my-zsh (it can get overridden).
zstyle ':completion:*' menu select

# Ensure LS_COLORS is set (Ubuntu doesn't always export it in zsh).
if [[ -z "$LS_COLORS" ]]; then
    if command -v dircolors &>/dev/null; then
        eval "$(dircolors -b)"
    else
        export LS_COLORS='di=1;34:ln=36:so=35:pi=33:ex=32:bd=1;33:cd=1;33:su=37;41:sg=30;43:tw=30;42:ow=34;42'
    fi
fi

# Group completions by type with headers (── directory ──, ── file ──, etc.)
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%B── %d ──%b%f'
zstyle ':completion:*:warnings'     format '%F{red}── no matches ──%f'
zstyle ':completion:*:messages'     format '%F{cyan}%d%f'

# Color completions by file type (dirs=blue, exes=green, symlinks=cyan)
# and highlight the currently selected item.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:default' list-colors "${(s.:.)LS_COLORS}"

# Case-insensitive + partial matching ("doc" → "Documents", "dl" → "Downloads")
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'

# Show option/flag descriptions
zstyle ':completion:*' verbose yes

# Directories first for cd; don't offer . or ..
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*' ignore-parents parent pwd

# Completion cache (makes repeated completions instant)
[[ -d "$HOME/.zsh/cache" ]] || mkdir -p "$HOME/.zsh/cache"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

# kill: color PIDs and show process info
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# SSH/SCP: complete hostnames from known_hosts + config
_ssh_hosts=()
if [[ -r ~/.ssh/known_hosts ]]; then
    _ssh_hosts+=(${(f)"$(awk '{print $1}' ~/.ssh/known_hosts | tr ',' '\n' | sed 's/\[//;s/\]:.*//')"})
fi
if [[ -r ~/.ssh/config ]]; then
    _ssh_hosts+=(${(f)"$(grep -i '^Host ' ~/.ssh/config | awk '{for(i=2;i<=NF;i++) if($i !~ /[*?]/) print $i}')"})
fi
if (( ${#_ssh_hosts} )); then
    zstyle ':completion:*:(ssh|scp|rsync):*' hosts $_ssh_hosts
fi
unset _ssh_hosts

# ── Environment ──────────────────────────────────────────────────────

export EDITOR='nano'

# Keep PATH unique while prepending user bins.
typeset -U path PATH
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/bin" ]]        && path=("$HOME/bin" $path)
export PATH

# ── Utility: open URL/path with system opener ────────────────────────

_open_default() {
    local target="$1"
    if command -v xdg-open &>/dev/null; then
        xdg-open "$target" >/dev/null 2>&1 &
    elif command -v open &>/dev/null; then
        open "$target" >/dev/null 2>&1 &
    elif command -v wslview &>/dev/null; then
        wslview "$target" >/dev/null 2>&1 &
    else
        echo "No URL opener found (xdg-open/open/wslview)."
        return 1
    fi
}

# ── Aliases: Navigation & Files ──────────────────────────────────────

alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

if (( _lsd_installed )); then
    alias ls='lsd'
    alias l='lsd -l'
    alias la='lsd -la'
    alias ll='lsd -lah'
else
    alias l='ls -lFh'
    alias la='ls -lAFh'
    alias ll='ls -lAh --group-directories-first --color=auto'
fi
alias lt='tree -L 2'
alias ldot='command ls -ld .*'

# Use bat for cat (plain output, no paging).
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias catt='bat'
elif command -v batcat &>/dev/null; then
    alias cat='batcat --style=plain --paging=never'
    alias catt='batcat'
fi

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -I'         # Prompt only for >3 files or recursive deletes
alias mkdir='mkdir -pv'

alias grep='grep --color=auto'

alias df='df -h'
alias du='du -h'
alias free='free -h'
alias myip='curl -s ifconfig.me'
alias localip='hostname -I | awk "{print \$1}"'
alias h='history'
alias path='echo "$PATH" | tr ":" "\n"'

# Safety nets for recursive operations
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# Editor: cursor > code
if command -v cursor &>/dev/null; then
    alias c='cursor'
elif command -v code &>/dev/null; then
    alias c='code'
fi

# VPN helpers (if present)
[[ -x "$HOME/vpn/vpn-connect.sh" ]]    && alias vpn-connect='bash ~/vpn/vpn-connect.sh'
[[ -x "$HOME/vpn/vpn-disconnect.sh" ]] && alias vpn-disconnect='bash ~/vpn/vpn-disconnect.sh'
[[ -x "$HOME/vpn/vpn-status.sh" ]]     && alias vpn-status='bash ~/vpn/vpn-status.sh'

# ── Aliases: Git (extras beyond Oh My Zsh git plugin) ────────────────

alias glog='git log --oneline --decorate --graph'
alias glp='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias cdg='cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"'

# Interactive branch switcher (requires fzf)
if command -v fzf &>/dev/null; then
    unalias gbr 2>/dev/null
    function gbr {
        local branch
        branch=$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null | fzf) || return
        [[ -n "$branch" ]] && git checkout "$branch"
    }
fi

# Delete current branch and return to main/master
branch_bye() {
    local current main
    current=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || { echo "Not on a local branch"; return 1; }
    main=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    [[ -z "$main" ]] && main=$(git branch --list main master 2>/dev/null | sed 's/^[* ]*//' | head -n1)
    [[ -z "$main" ]] && main="main"
    [[ "$current" == "$main" ]] && { echo "Already on '$main'"; return 1; }
    git checkout "$main" && git branch -D "$current"
}

# Open PR/MR page in browser (GitHub + GitLab)
pr() {
    local remote_url repo_url branch
    remote_url=$(git config --get remote.origin.url) || { echo "No remote.origin.url found"; return 1; }

    case "$remote_url" in
        git@*:*)
            local host="${remote_url#git@}" repo_path="${remote_url#*:}"
            host="${host%%:*}"
            repo_url="https://${host}/${repo_path%.git}" ;;
        ssh://git@*)
            repo_url="https://${remote_url#ssh://git@}"
            repo_url="${repo_url%.git}" ;;
        http://*|https://*)
            repo_url="${remote_url%.git}" ;;
        *)
            echo "Unsupported remote URL: $remote_url"; return 1 ;;
    esac

    branch=$(git symbolic-ref --quiet --short HEAD) || { echo "Not on a local branch"; return 1; }

    if echo "$repo_url" | grep -qi "gitlab"; then
        local mr_url="${repo_url}/-/merge_requests/new?merge_request[source_branch]=${branch}"
        if command -v glab >/dev/null 2>&1; then
            glab mr create --web >/dev/null 2>&1 || _open_default "$mr_url" || echo "$mr_url"
        else
            _open_default "$mr_url" || echo "$mr_url"
        fi
    else
        local pr_url="${repo_url}/pull/new/${branch}"
        _open_default "$pr_url" || echo "$pr_url"
    fi
}

# ── Aliases: Python ──────────────────────────────────────────────────

alias v='source .venv/bin/activate 2>/dev/null || source venv/bin/activate 2>/dev/null || echo "No .venv or venv found"'
alias pyrun='python -m'
alias pyserver='python -m http.server'
alias psync='poetry install --sync'
alias plock='poetry lock && poetry install'

# Auto-activate/deactivate virtualenvs on cd
autoload -Uz add-zsh-hook
_venv_auto_activate() {
    if [[ -z "$VIRTUAL_ENV" ]]; then
        if [[ -d .venv ]]; then
            source .venv/bin/activate 2>/dev/null
        elif [[ -d venv ]]; then
            source venv/bin/activate 2>/dev/null
        fi
    else
        # Deactivate if we've left the project directory
        local project_dir="${VIRTUAL_ENV%/*}"
        if [[ "$PWD/" != "$project_dir/"* ]]; then
            deactivate 2>/dev/null
        fi
    fi
}
add-zsh-hook chpwd _venv_auto_activate
_venv_auto_activate

# ── FZF configuration ────────────────────────────────────────────────

if command -v fzf &>/dev/null; then
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    elif command -v fdfind &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
        export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
    fi
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND:-}"

    # Neutral color scheme (works on light and dark terminals)
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

    # Preview with bat if available
    if command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
    elif command -v batcat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --line-range :500 {}'"
    fi
fi

# ── Functions ────────────────────────────────────────────────────────

# Find files by name
ff() { find . -type f -iname "*${1:?usage: ff PATTERN}*" 2>/dev/null; }

# Find text in files (prefer ripgrep)
ftext() {
    local pattern="${1:?usage: ftext PATTERN}"
    if command -v rg &>/dev/null; then
        rg "$pattern"
    else
        grep -rnw . -e "$pattern" 2>/dev/null
    fi
}

# Show listening ports/processes
ports() {
    if command -v ss &>/dev/null; then
        ss -tulanp
    elif command -v netstat &>/dev/null; then
        netstat -tulanp
    else
        echo "No port tool found (install iproute2 or net-tools)."
        return 1
    fi
}

# Open current directory in file manager
f() { _open_default "."; }

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Create or attach to a tmux session
# Usage: tm [session-name]  (default: "main")
tm() { tmux new -A -s "${1:-main}"; }

# Show disk usage of directories (top 10)
ducks() { du -cks -- * 2>/dev/null | sort -rn | head -11; }

# Quick reload
alias reload='source ~/.zshrc && echo "✓ zsh config reloaded"'

# ── History ──────────────────────────────────────────────────────────

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# ── Autosuggestions ──────────────────────────────────────────────────

# History-only suggestions avoid expensive completion lookups that can feel like hangs.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'  # visible ghost text on both light/dark

# Keep autosuggest acceptance explicit: Tab/Right (not Up/Down).
typeset -ga ZSH_AUTOSUGGEST_ACCEPT_WIDGETS
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
    end-of-line
    vi-end-of-line
    vi-add-eol
    vi-forward-char
    forward-char
)

typeset -ga ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
    forward-word
)

# ── Shell QoL options ────────────────────────────────────────────────

setopt AUTO_CD              # Type a dir name to cd into it (no 'cd' needed)
setopt AUTO_PUSHD           # cd pushes onto the dir stack (use 'cd -N' to go back)
setopt PUSHD_IGNORE_DUPS    # No duplicate dirs on the stack
setopt PUSHD_SILENT         # Don't print dir stack after pushd/popd
setopt CORRECT              # Offer correction for mistyped commands (not args)
setopt INTERACTIVE_COMMENTS # Allow # comments in interactive shell
setopt GLOB_DOTS            # Include dotfiles in glob patterns

# ── Key bindings ─────────────────────────────────────────────────────

# Sticky prefix history search: keeps original typed query while cycling.
typeset -g _history_prefix_query=""
_history_prefix_search_up() {
    if [[ $LASTWIDGET != _history_prefix_search_up &&
          $LASTWIDGET != _history_prefix_search_down &&
          $LASTWIDGET != up-line-or-beginning-search &&
          $LASTWIDGET != down-line-or-beginning-search ]]; then
        _history_prefix_query="$BUFFER"
    fi
    BUFFER="$_history_prefix_query"
    CURSOR=${#BUFFER}
    zle up-line-or-beginning-search
}
_history_prefix_search_down() {
    if [[ $LASTWIDGET != _history_prefix_search_up &&
          $LASTWIDGET != _history_prefix_search_down &&
          $LASTWIDGET != up-line-or-beginning-search &&
          $LASTWIDGET != down-line-or-beginning-search ]]; then
        _history_prefix_query="$BUFFER"
    fi
    BUFFER="$_history_prefix_query"
    CURSOR=${#BUFFER}
    zle down-line-or-beginning-search
}
zle -N _history_prefix_search_up
zle -N _history_prefix_search_down

if [[ -o interactive ]]; then
    autoload -U up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search

    # Arrow keys → sticky prefix history search
    [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" _history_prefix_search_up
    [[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" _history_prefix_search_down
    bindkey '^[[A' _history_prefix_search_up
    bindkey '^[[B' _history_prefix_search_down
    bindkey '^[OA' _history_prefix_search_up
    bindkey '^[OB' _history_prefix_search_down
    bindkey '^P'   _history_prefix_search_up
    bindkey '^N'   _history_prefix_search_down
    bindkey '^I'   expand-or-complete
    bindkey '^[[Z' reverse-menu-complete      # Shift+Tab
    if (( $+widgets[autosuggest-accept] )); then
        bindkey '^ '   autosuggest-accept      # Ctrl+Space
        bindkey '^@'   autosuggest-accept      # Ctrl+Space (tmux)
    fi

    # Completion menu navigation
    bindkey -M menuselect '^I'   menu-complete
    bindkey -M menuselect '^[[Z' reverse-menu-complete
    [[ -n "${terminfo[kcuu1]}" ]] && bindkey -M menuselect "${terminfo[kcuu1]}" up-line-or-history
    [[ -n "${terminfo[kcud1]}" ]] && bindkey -M menuselect "${terminfo[kcud1]}" down-line-or-history
    bindkey -M menuselect '^[[A' up-line-or-history
    bindkey -M menuselect '^[[B' down-line-or-history
    bindkey -M menuselect '^[OA' up-line-or-history
    bindkey -M menuselect '^[OB' down-line-or-history

    # Right-arrow/End: accept autosuggestion at end of line
    bindkey '^[[C' forward-char
    bindkey '^[OC' forward-char
    bindkey '^[[F' end-of-line
    bindkey '^[OF' end-of-line

    # Ctrl+Right: accept one word of autosuggestion
    bindkey '^[[1;5C' forward-word
    bindkey '^[f'     forward-word            # Alt+F fallback

    # Ctrl+Z: undo last edit on command line
    bindkey '^Z' undo
fi

# ── Pyenv (if installed) ────────────────────────────────────────────

if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    if pyenv commands 2>/dev/null | grep -q virtualenv-init; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi

# ── Powerlevel10k config ─────────────────────────────────────────────

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ── Local overrides (not managed by setup script) ────────────────────

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ── Syntax highlighting (must be last to hook all widgets) ───────────

if (( _zsh_syntax_highlighting_enabled )); then
    # Don't use $+functions[_zsh_highlight] as a guard: the
    # zsh-history-substring-search plugin defines a same-named function.
    if [[ -z "${ZSH_HIGHLIGHT_VERSION:-}" ]]; then
        [[ -r "$_zsh_highlight_plugin" ]] && source "$_zsh_highlight_plugin"
    fi

    if (( $+functions[_zsh_highlight_highlighter_main_paint] )); then
        typeset -gA ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
        ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow,bold'
        ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'

        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main pattern)
        typeset -gA ZSH_HIGHLIGHT_PATTERNS
        ZSH_HIGHLIGHT_PATTERNS+=('http://*' 'fg=cyan,underline')
        ZSH_HIGHLIGHT_PATTERNS+=('https://*' 'fg=cyan,underline')
    fi
fi
