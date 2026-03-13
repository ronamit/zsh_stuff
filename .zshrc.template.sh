# Fastfetch: show system info before instant prompt (local sessions only).
# Must run before the p10k instant prompt block to avoid console-output warnings.
if [[ -z "${SSH_CONNECTION:-}" && -o interactive ]] && command -v fastfetch &>/dev/null; then
    fastfetch
fi

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

# Disable mouse reporting so scroll in SSH (and plain shells) doesn't dump raw escape codes.
# Apps like vim/less will re-enable it when they start.
if [[ -o interactive && -t 1 ]]; then
    printf '\e[?1000l\e[?1002l\e[?1006l'
fi

HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13
HIST_STAMPS="yyyy-mm-dd"

# ── Plugin detection & compatibility ─────────────────────────────────

_fzf_tab_plugin="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh"
_zsh_autosuggest_plugin="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
_zsh_highlight_plugin="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
typeset -gi _fzf_tab_loaded=0
[[ -r "$_fzf_tab_plugin" ]] && _fzf_tab_loaded=1
typeset -gi _zsh_autosuggest_loaded=0
[[ -r "$_zsh_autosuggest_plugin" ]] && _zsh_autosuggest_loaded=1
typeset -gi _lsd_installed=0
command -v lsd &>/dev/null && _lsd_installed=1
typeset -gi _zsh_syntax_highlighting_enabled=1
typeset -gi _command_not_found_enabled=1

# command-not-found can add latency on slower/remote sessions.
# Defaults: disabled over SSH, enabled locally. Override with:
#   ZSH_ENABLE_COMMAND_NOT_FOUND=1  (force on)
#   ZSH_ENABLE_COMMAND_NOT_FOUND=0  (force off)
if [[ -n "${SSH_CONNECTION:-}${SSH_CLIENT:-}${SSH_TTY:-}" ]]; then
    _command_not_found_enabled=0
fi
if [[ -n "${ZSH_ENABLE_COMMAND_NOT_FOUND:-}" ]]; then
    case "${ZSH_ENABLE_COMMAND_NOT_FOUND:l}" in
        1|on|true|yes) _command_not_found_enabled=1 ;;
        0|off|false|no) _command_not_found_enabled=0 ;;
    esac
fi

plugins=(
    git
    colored-man-pages
    extract
    fzf
    zsh-history-substring-search
)
# Load z plugin only when zoxide is not installed (zoxide provides the z command)
command -v zoxide &>/dev/null || plugins+=(z)
(( _command_not_found_enabled )) && plugins+=(command-not-found)

# Load complist (provides menu-select widget for navigable completion menus).
zmodload -i zsh/complist

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# fzf-tab gives interactive fuzzy completion without zsh-autocomplete's
# async completion pipeline, which can hang on heavy git completions.
if (( _fzf_tab_loaded )); then
    source "$_fzf_tab_plugin"
    zstyle ':fzf-tab:*' fzf-flags '--height=40% --layout=reverse --border'
    zstyle ':fzf-tab:*' switch-group ',' '.'
    # Press / in the fzf-tab menu to accept a directory and immediately complete the next path component
    zstyle ':fzf-tab:*' continuous-trigger '/'
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

# Keep completion output minimal (no category headers like "local directory").
# You still get completion candidates and menu-select behavior.

# Color completions by file type (dirs=blue, exes=green, symlinks=cyan)
# and highlight the currently selected item.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:default' list-colors "${(s.:.)LS_COLORS}"

# Case-insensitive + partial matching ("doc" → "Documents", "dl" → "Downloads")
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'

# Keep completion lists clean and compact.
zstyle ':completion:*' verbose no

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

# SSH/SCP: cache hostnames from known_hosts + ssh config to keep startup fast.
_ssh_cache_file="$HOME/.zsh/cache/ssh_hosts"
_refresh_ssh_hosts_cache=0
[[ ! -f "$_ssh_cache_file" ]] && _refresh_ssh_hosts_cache=1
[[ -r ~/.ssh/known_hosts && ~/.ssh/known_hosts -nt "$_ssh_cache_file" ]] && _refresh_ssh_hosts_cache=1
[[ -r ~/.ssh/config && ~/.ssh/config -nt "$_ssh_cache_file" ]] && _refresh_ssh_hosts_cache=1
if (( _refresh_ssh_hosts_cache )); then
    {
        if [[ -r ~/.ssh/known_hosts ]]; then
            awk '{print $1}' ~/.ssh/known_hosts \
                | tr ',' '\n' \
                | sed 's/\[//;s/\]:.*//' \
                | grep -vE '^(\||#|$)'
        fi
        if [[ -r ~/.ssh/config ]]; then
            grep -i '^Host ' ~/.ssh/config | awk '{for(i=2;i<=NF;i++) if($i !~ /[*?]/) print $i}'
        fi
    } | grep -vE '^\s*$' | sort -u >| "$_ssh_cache_file"
fi
_ssh_hosts=()
[[ -r "$_ssh_cache_file" ]] && _ssh_hosts=(${(f)"$(cat "$_ssh_cache_file")"})
if (( ${#_ssh_hosts} )); then
    zstyle ':completion:*:(ssh|scp|rsync):*' hosts $_ssh_hosts
fi
unset _ssh_hosts _ssh_cache_file _refresh_ssh_hosts_cache

# ── Environment ──────────────────────────────────────────────────────

export EDITOR='nano'

# Keep PATH unique while prepending user bins.
typeset -U path PATH
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/bin" ]]        && path=("$HOME/bin" $path)
export PATH

# zoxide: smarter cd with frequency+recency ranking (overrides z plugin's z command when installed)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# run-help: Alt+H or "help <cmd>" shows man for builtins/commands (e.g. help git).
autoload -Uz run-help
unalias run-help 2>/dev/null
alias help=run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-sudo run-help-svn

# Colored man pages (bold/underline in less); plugin adds semantics, this improves rendering.
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;38;5;74m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[38;5;246m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[04;38;5;146m'

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
alias -- -='cd -'   # Go to previous directory (complements AUTO_PUSHD)

if (( _lsd_installed )); then
    alias ls='lsd'
    alias l='lsd -l'
    alias la='lsd -la'
    alias ll='lsd -lah'
else
    alias l='ls -lFh'
    alias la='ls -lAFh'
    # GNU ls: group dirs first + color; macOS/BSD: plain -lAh
    if ls --group-directories-first -d . &>/dev/null 2>&1; then
        alias ll='ls -lAh --group-directories-first --color=auto'
    else
        alias ll='ls -lAh'
    fi
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
command -v free &>/dev/null && alias free='free -h'
alias myip='curl -s ifconfig.me'
# Local IP: Linux (hostname -I) or macOS (ipconfig getifaddr)
localip() {
    if command -v hostname &>/dev/null && hostname -I &>/dev/null; then
        hostname -I | awk '{print $1}'
    elif command -v ipconfig &>/dev/null; then
        ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "No primary IP"
    else
        echo "No localip helper"
    fi
}
alias h='history'
alias path='echo "$PATH" | tr ":" "\n"'

# Safety nets for recursive operations (GNU only; macOS BSD chown/chmod lack these)
if [[ "$(uname -s)" != "Darwin" ]]; then
    alias chown='chown --preserve-root'
    alias chmod='chmod --preserve-root'
    alias chgrp='chgrp --preserve-root'
fi

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

# SSH wrapper for VPN-required hosts.
# Behavior:
#   - Runs ssh as usual.
#   - If ssh fails in an interactive terminal, asks whether to run vpn-connect.
#   - On confirmation, runs vpn-connect and retries ssh once.
ssh() {
    command ssh "$@"
    local ssh_rc=$?
    (( ssh_rc == 0 )) && return 0

    if [[ ! -t 0 || ! -t 1 ]]; then
        return "$ssh_rc"
    fi

    printf "ssh failed (exit %d). Run vpn-connect and retry? [y/N] " "$ssh_rc"
    local reply
    read -r reply
    case "${reply:l}" in
        y|yes)
            if (( $+aliases[vpn-connect] )); then
                vpn-connect || { echo "ssh wrapper: vpn-connect failed."; return "$ssh_rc"; }
            elif [[ -x "$HOME/vpn/vpn-connect.sh" ]]; then
                bash "$HOME/vpn/vpn-connect.sh" || { echo "ssh wrapper: vpn-connect failed."; return "$ssh_rc"; }
            else
                echo "ssh wrapper: vpn-connect is not available."
                return "$ssh_rc"
            fi
            command ssh "$@"
            return $?
            ;;
        *)
            return "$ssh_rc"
            ;;
    esac
}

# ── Aliases: Git (extras beyond Oh My Zsh git plugin) ────────────────

alias glog='git log --oneline --decorate --graph'
alias glp='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias cdg='cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"'
command -v lazygit &>/dev/null && alias lg='lazygit'

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
ff() {
    local pattern="${1:?usage: ff PATTERN}"
    if command -v fd &>/dev/null; then
        fd -HI -t f --glob "*${pattern}*" .
    elif command -v fdfind &>/dev/null; then
        fdfind -HI -t f --glob "*${pattern}*" .
    else
        find . -type f -iname "*${pattern}*" 2>/dev/null
    fi
}

# Find text in files (prefer ripgrep)
ftext() {
    local pattern="${1:?usage: ftext PATTERN}"
    if command -v rg &>/dev/null; then
        rg --smart-case --hidden -g '!.git' "$pattern"
    else
        grep -RIn --exclude-dir=.git -e "$pattern" . 2>/dev/null
    fi
}

# Show listening ports/processes
ports() {
    if command -v ss &>/dev/null; then
        ss -tulanp
    elif command -v netstat &>/dev/null; then
        if [[ "$(uname -s)" == "Darwin" ]]; then
            local netstat_out
            netstat_out="$(netstat -an -f inet | grep -E 'LISTEN|ESTABLISHED' || true)"
            if [[ -n "$netstat_out" ]]; then
                echo "$netstat_out"
            else
                echo "No LISTEN/ESTABLISHED IPv4 sockets found."
            fi
        else
            netstat -tulanp
        fi
    elif command -v lsof &>/dev/null; then
        lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null
    else
        echo "No port tool found (install ss, netstat, or lsof)."
        return 1
    fi
}

# Open current directory in file manager
f() { _open_default "."; }

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Create or attach to a tmux session
# Usage: tm [session-name]  (default: "main")
tm() {
    local session="${1:-main}"

    if [[ -n "$TMUX" ]]; then
        if tmux has-session -t "$session" 2>/dev/null; then
            tmux switch-client -t "$session"
        else
            tmux new-session -d -s "$session" && tmux switch-client -t "$session"
        fi
    else
        tmux new-session -A -s "$session"
    fi
}

# Show disk usage of directories (top 10)
ducks() { du -sh * 2>/dev/null | sort -hr | head -11; }

# Quick reload
alias reload='source ~/.zshrc && echo "✓ zsh config reloaded"'

# ── History ──────────────────────────────────────────────────────────

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
typeset -g _share_history_pref="${ZSH_SHARE_HISTORY:-0}"
case "${_share_history_pref:l}" in
    1|on|true|yes) setopt SHARE_HISTORY ;;
    *) unsetopt SHARE_HISTORY ;;
esac
unset _share_history_pref
# INC_APPEND_HISTORY is implied by SHARE_HISTORY; only set when not sharing.
[[ -o sharehistory ]] || setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# ── Autosuggestions ──────────────────────────────────────────────────

# Show suggestions as you type (history first, then completion fallback).
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'  # visible ghost text on both light/dark
# We define custom widgets later, so do one bind pass after all widget changes.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Load autosuggestions after fzf-tab to avoid widget conflicts.
if (( _zsh_autosuggest_loaded )); then
    source "$_zsh_autosuggest_plugin"
fi

# Keep autosuggest acceptance explicit: Tab/Right (not Up/Down).
typeset -ga ZSH_AUTOSUGGEST_ACCEPT_WIDGETS
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
    autosuggest-accept
    end-of-line
    vi-end-of-line
    vi-add-eol
)

typeset -ga ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
    vi-forward-char
    forward-char
    forward-word
)

# ── Shell QoL options ────────────────────────────────────────────────

# Prevent accidental Ctrl+S from freezing terminal output (XON/XOFF flow control),
# which is especially confusing inside tmux over SSH.
if [[ -o interactive ]]; then
    stty -ixon -ixoff 2>/dev/null || true
fi

setopt AUTO_CD              # Type a dir name to cd into it (no 'cd' needed)
setopt AUTO_PUSHD           # cd pushes onto the dir stack (use 'cd -N' to go back)
setopt PUSHD_IGNORE_DUPS    # No duplicate dirs on the stack
setopt PUSHD_SILENT         # Don't print dir stack after pushd/popd
typeset -g _correct_pref="${ZSH_ENABLE_CORRECTION:-0}"
case "${_correct_pref:l}" in
    1|on|true|yes) setopt CORRECT ;;  # Offer correction for mistyped commands
    *) unsetopt CORRECT ;;
esac
unset _correct_pref
setopt INTERACTIVE_COMMENTS # Allow # comments in interactive shell
setopt GLOB_DOTS            # Include dotfiles in glob patterns
setopt AUTO_LIST            # Show completion options below prompt on ambiguous matches
setopt AUTO_MENU            # Repeated completion keys cycle through matches
unsetopt MENU_COMPLETE      # Keep list+menu behavior instead of replacing buffer immediately

# Prompt before printing very large completion lists (prevents terminal spam).
LISTMAX=20

# ── Key bindings ─────────────────────────────────────────────────────

# Sticky prefix history search: keeps original typed query while cycling.
# Uses raw .history-beginning-search-{backward,forward} builtins to avoid
# continuation-state conflicts with the autoloaded up/down-line-or-beginning-search
# wrappers (which check LASTWIDGET internally and break when called from our widgets).
typeset -g _history_prefix_query=""
_history_prefix_search_up() {
    if [[ $LASTWIDGET != _history_prefix_search_up &&
          $LASTWIDGET != _history_prefix_search_down &&
          $LASTWIDGET != _down_history_or_dirs ]]; then
        _history_prefix_query="$BUFFER"
    fi
    BUFFER="$_history_prefix_query"
    CURSOR=${#BUFFER}
    zle .history-beginning-search-backward
    zle .end-of-line
}
_history_prefix_search_down() {
    if [[ $LASTWIDGET != _history_prefix_search_up &&
          $LASTWIDGET != _history_prefix_search_down &&
          $LASTWIDGET != _down_history_or_dirs ]]; then
        _history_prefix_query="$BUFFER"
    fi
    BUFFER="$_history_prefix_query"
    CURSOR=${#BUFFER}
    if zle .history-beginning-search-forward; then
        zle .end-of-line
    else
        # No more forward matches — restore original input
        BUFFER="$_history_prefix_query"
        CURSOR=${#BUFFER}
    fi
}
zle -N _history_prefix_search_up
zle -N _history_prefix_search_down

# Smart Down: keep history scrolling when active; otherwise cycle path
# completions for cd/pushd/popd, AUTO_CD-style path input, or path-like args.
_down_history_or_dirs() {
    local cmd="${BUFFER%%[[:space:]]*}"
    local in_history_scroll=0
    local in_dir_context=0
    local -a words=()
    local current_word=""

    if [[ $LASTWIDGET == _history_prefix_search_up ||
          $LASTWIDGET == _history_prefix_search_down ||
          $LASTWIDGET == _down_history_or_dirs ]]; then
        in_history_scroll=1
    fi

    if [[ $CURSOR -eq ${#BUFFER} ]]; then
        if [[ "$cmd" == "cd" || "$cmd" == "pushd" || "$cmd" == "popd" ]]; then
            in_dir_context=1
        elif [[ "$BUFFER" != *[[:space:]]* ]] && [[ "$BUFFER" == [./~]* ]]; then
            in_dir_context=1
        else
            words=(${(z)BUFFER})
            if [[ "$BUFFER" != *[[:space:]] ]] && (( ${#words} )); then
                current_word="${words[-1]}"
                if [[ "$current_word" == [./~]* || "$current_word" == */* ]]; then
                    in_dir_context=1
                fi
            fi
        fi
    fi

    if (( in_history_scroll )); then
        zle _history_prefix_search_down
    elif (( in_dir_context )); then
        zle menu-complete
    else
        zle _history_prefix_search_down
    fi
}
zle -N _down_history_or_dirs

_tab_complete_and_autolist() {
    # Complete current token, then refresh candidate list for the new context
    # (e.g., after completing "dir/", immediately show its subdirectories).
    if (( $+widgets[expand-or-complete] )); then
        zle expand-or-complete
    else
        zle .expand-or-complete
    fi
    zle _maybe_auto_list_choices
}
zle -N _tab_complete_and_autolist

_tab_accept_or_complete() {
    # Preserve Tab-to-accept when an autosuggestion is visible; otherwise run
    # normal completion flow.
    local _before_buffer="$BUFFER"
    local -i _before_cursor=$CURSOR

    if (( $+widgets[autosuggest-accept] )); then
        zle autosuggest-accept
    fi

    if [[ "$BUFFER" != "$_before_buffer" || $CURSOR -ne $_before_cursor ]]; then
        # Autosuggestion was accepted — append / if last word is a directory.
        local -a _words=(${(z)BUFFER})
        if (( ${#_words} )); then
            local _last="${_words[-1]}"
            # Expand ~ to $HOME for the directory test
            local _expanded="${_last/#\~/$HOME}"
            if [[ -d "$_expanded" && "$BUFFER" != */ ]]; then
                BUFFER="${BUFFER}/"
                CURSOR=${#BUFFER}
            fi
        fi
        return 0
    fi

    zle _tab_complete_and_autolist
}
zle -N _tab_accept_or_complete

# Auto-show completion list while typing (for manageable candidate sets).
# Configurable: 1/on/true/yes enables; 0/off/false/no disables.
# Default is enabled for immediate `cd`/path candidate previews while typing.
: "${ZSH_AUTOLIST_ON_TYPE:=1}"
# When typing `cd ` + space with an empty argument, auto-open early only when
# local directory count is small (keeps this useful but non-spammy).
: "${ZSH_AUTOLIST_CD_EMPTY_MAX:=20}"
typeset -g _auto_list_last_buffer=""
typeset -gi _auto_list_in_paste=0
typeset -g _autolist_cd_cache_pwd=""
typeset -gi _autolist_cd_cache_count=-1
typeset -gi _autolist_cd_cache_limit=-1

_autolist_invalidate_cd_cache() {
    _autolist_cd_cache_pwd=""
    _autolist_cd_cache_count=-1
    _autolist_cd_cache_limit=-1
}

_should_autolist_empty_cd_arg() {
    local _raw="${ZSH_AUTOLIST_CD_EMPTY_MAX:-20}"
    local -i _max=20
    local -i _count=0
    local _d

    [[ "$_raw" == <-> ]] && _max=$_raw
    (( _max < 0 )) && _max=0

    # Reuse count in same directory to avoid repeated glob scans while typing.
    if [[ "$_autolist_cd_cache_pwd" == "$PWD" && $_autolist_cd_cache_count -ge 0 ]] \
       && (( _autolist_cd_cache_limit < 0 || _max <= _autolist_cd_cache_limit )); then
        _count=$_autolist_cd_cache_count
    else
        # Count local directory candidates quickly and stop once threshold is passed.
        setopt localoptions nullglob
        for _d in * .*; do
            [[ "$_d" == "." || "$_d" == ".." ]] && continue
            [[ -d "$_d" ]] || continue
            (( _count++ ))
            (( _count > _max )) && break
        done
        _autolist_cd_cache_pwd="$PWD"
        _autolist_cd_cache_count=$_count
        if (( _count > _max )); then
            _autolist_cd_cache_limit=$_max
        else
            _autolist_cd_cache_limit=-1
        fi
    fi
    (( _count <= _max ))
}

_maybe_auto_list_choices() {
    # Only while typing at end-of-line; avoid noisy redraws.
    (( _auto_list_in_paste )) && return
    (( KEYS_QUEUED_COUNT > 0 )) && return
    (( CURSOR == ${#BUFFER} )) || return
    [[ "$LBUFFER" == "$_auto_list_last_buffer" ]] && return

    local -a _words
    local _current _cmd _is_cd_context=0 _is_ssh_context=0 _has_trailing_space=0
    [[ "$LBUFFER" == *[[:space:]] ]] && _has_trailing_space=1
    _words=(${(z)LBUFFER})
    (( ${#_words} )) || return
    _current="${_words[-1]}"
    _cmd="${_words[1]}"

    # Always allow path completion previews for cd-like commands once an
    # argument has started (e.g., "cd D" should immediately list candidates).
    if [[ "$_cmd" == "cd" || "$_cmd" == "pushd" || "$_cmd" == "popd" ]]; then
        (( ${#_words} >= 2 )) && _is_cd_context=1
    fi
    if [[ "$_cmd" == "ssh" || "$_cmd" == "scp" || "$_cmd" == "rsync" ]]; then
        (( ${#_words} >= 2 )) && _is_ssh_context=1
    fi

    # After a space, refresh completions for the next argument position.
    if (( _has_trailing_space )); then
        # On bare `cd `, only auto-open if candidate set is small.
        if [[ "$_cmd" == "cd" || "$_cmd" == "pushd" || "$_cmd" == "popd" ]]; then
            if (( ${#_words} == 1 )); then
                if _should_autolist_empty_cd_arg; then
                    _auto_list_last_buffer="$LBUFFER"
                    zle list-choices
                fi
                return
            fi
        fi

        # Keep command-position noise off in auto mode.
        (( ${#_words} >= 2 )) || return
        # Restrict auto-popups to path/host oriented commands.
        if [[ "$_cmd" != "cd" && "$_cmd" != "pushd" && "$_cmd" != "popd" &&
              "$_cmd" != "ls" && "$_cmd" != "cat" && "$_cmd" != "less" &&
              "$_cmd" != "more" && "$_cmd" != "vim" && "$_cmd" != "nano" &&
              "$_cmd" != "rm" && "$_cmd" != "cp" && "$_cmd" != "mv" &&
              "$_cmd" != "mkdir" && "$_cmd" != "rmdir" && "$_cmd" != "touch" &&
              "$_cmd" != "ssh" && "$_cmd" != "scp" && "$_cmd" != "rsync" ]]; then
            return
        fi
        _auto_list_last_buffer="$LBUFFER"
        zle list-choices
        return
    fi

    # Keep command-position auto-list quiet (avoid external command spam).
    if (( ${#_words} == 1 )) && [[ "$_current" != */* && "$_current" != .* && "$_current" != ~* ]]; then
        return
    fi

    # Don't spam for tiny prefixes or option flags.
    [[ -n "$_current" ]] || return
    if (( ! _is_cd_context )); then
        (( ${#_current} >= 2 )) || return
        [[ "$_current" == -* ]] && return
    fi

    # Keep it focused to common completion contexts.
    if (( _is_cd_context || _is_ssh_context )) || \
       [[ "$_current" == */* || "$_current" == .* || "$_current" == ~* || "$_current" == <-> ]]; then
        _auto_list_last_buffer="$LBUFFER"
        zle list-choices
    fi
}
zle -N _maybe_auto_list_choices

_self_insert_with_autolist() {
    (( _auto_list_in_paste || KEYS_QUEUED_COUNT > 0 )) && {
        if (( $+widgets[autosuggest-self-insert] )); then
            zle autosuggest-self-insert
        else
            zle .self-insert
        fi
        return
    }

    if (( $+widgets[autosuggest-self-insert] )); then
        zle autosuggest-self-insert
    else
        zle .self-insert
    fi
    zle _maybe_auto_list_choices
}
zle -N _self_insert_with_autolist

_magic_space_with_autolist() {
    if (( $+widgets[autosuggest-magic-space] )); then
        zle autosuggest-magic-space
    else
        zle .magic-space
    fi
    _auto_list_last_buffer=""
    zle _maybe_auto_list_choices
}
zle -N _magic_space_with_autolist

_accept_line_with_autolist_reset() {
    _auto_list_last_buffer=""
    if (( $+widgets[autosuggest-accept-line] )); then
        zle autosuggest-accept-line
    else
        zle .accept-line
    fi
}
zle -N _accept_line_with_autolist_reset

_bracketed_paste_with_autolist() {
    _auto_list_in_paste=1
    if (( $+widgets[autosuggest-bracketed-paste] )); then
        zle autosuggest-bracketed-paste
    else
        zle .bracketed-paste
    fi
    _auto_list_in_paste=0
    _auto_list_last_buffer=""
}
zle -N _bracketed_paste_with_autolist

_autolist_is_enabled() {
    local _v="${ZSH_AUTOLIST_ON_TYPE:-1}"
    _v="${_v:l}"
    [[ "$_v" == "1" || "$_v" == "on" || "$_v" == "true" || "$_v" == "yes" ]]
}

_apply_autolist_mode() {
    if _autolist_is_enabled; then
        zle -N self-insert _self_insert_with_autolist
        zle -N magic-space _magic_space_with_autolist
        zle -N accept-line _accept_line_with_autolist_reset
        zle -N bracketed-paste _bracketed_paste_with_autolist
    else
        if (( $+widgets[autosuggest-self-insert] )); then
            zle -A autosuggest-self-insert self-insert
        else
            zle -A .self-insert self-insert
        fi
        if (( $+widgets[autosuggest-magic-space] )); then
            zle -A autosuggest-magic-space magic-space
        else
            zle -A .magic-space magic-space
        fi
        if (( $+widgets[autosuggest-accept-line] )); then
            zle -A autosuggest-accept-line accept-line
        else
            zle -A .accept-line accept-line
        fi
        if (( $+widgets[autosuggest-bracketed-paste] )); then
            zle -A autosuggest-bracketed-paste bracketed-paste
        elif (( $+widgets[.bracketed-paste] )); then
            zle -A .bracketed-paste bracketed-paste
        fi
    fi
}

# Keep directory-count cache fresh while avoiding repeated scans in a single edit.
if (( $+functions[add-zsh-hook] )); then
    add-zsh-hook -D chpwd _autolist_invalidate_cd_cache 2>/dev/null
    add-zsh-hook chpwd _autolist_invalidate_cd_cache
    add-zsh-hook -D precmd _autolist_invalidate_cd_cache 2>/dev/null
    add-zsh-hook precmd _autolist_invalidate_cd_cache
fi

if [[ -o interactive ]]; then
    # Apply current auto-list mode (on by default, configurable).
    _apply_autolist_mode

    # Arrow keys → sticky prefix history search
    [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" _history_prefix_search_up
    [[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" _down_history_or_dirs
    bindkey '^[[A' _history_prefix_search_up
    bindkey '^[[B' _down_history_or_dirs
    bindkey '^[OA' _history_prefix_search_up
    bindkey '^[OB' _down_history_or_dirs
    bindkey '^P'   _history_prefix_search_up
    bindkey '^N'   _down_history_or_dirs
    bindkey '^I' _tab_accept_or_complete
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
    # Avoid pyenv/conda PATH collisions when conda is active.
    # Override with ZSH_FORCE_PYENV=1 to keep pyenv wrappers enabled.
    typeset -gi _conda_active=0
    [[ -n "${CONDA_PREFIX:-}" ]] && _conda_active=1
    if [[ "${CONDA_SHLVL:-0}" == <-> ]] && (( CONDA_SHLVL > 0 )); then
        _conda_active=1
    fi
    if (( ! _conda_active )) || [[ "${ZSH_FORCE_PYENV:-0}" == "1" ]]; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        _pyenv_bootstrap() {
            unfunction _pyenv_bootstrap pyenv python pip pip3 2>/dev/null
            eval "$(command pyenv init -)"
            if command pyenv commands 2>/dev/null | grep -q virtualenv-init; then
                eval "$(command pyenv virtualenv-init -)"
            fi
        }
        pyenv()  { _pyenv_bootstrap; command pyenv "$@"; }
        python() { _pyenv_bootstrap; command python "$@"; }
        pip()    { _pyenv_bootstrap; command pip "$@"; }
        pip3()   { _pyenv_bootstrap; command pip3 "$@"; }
    fi
    unset _conda_active
fi

# ── Powerlevel10k config ─────────────────────────────────────────────

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ── Local overrides (not managed by setup script) ────────────────────

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Allow ~/.zshrc.local to toggle auto-list mode without editing this file.
if [[ -o interactive ]] && (( $+functions[_apply_autolist_mode] )); then
    _apply_autolist_mode
fi

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

        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
    fi

    # Re-wrap any widgets created or reassigned earlier in this file.
    if (( $+functions[_zsh_highlight_bind_widgets] )); then
        _zsh_highlight_bind_widgets
    fi
fi

# With manual rebind enabled, wrap final widget set once at the very end.
if (( $+functions[_zsh_autosuggest_bind_widgets] )); then
    _zsh_autosuggest_bind_widgets
fi
