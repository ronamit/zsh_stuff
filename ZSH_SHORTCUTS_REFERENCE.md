# ZSH Shortcuts Reference

Shortcut and helper reference for this setup, based on `.zshrc.template.sh`.

## See What Is Active

```bash
# List aliases
alias

# List custom functions from this config
functions | rg '^(ff|ftext|ports|f|mkcd|tm|ducks|gbr|branch_bye|pr|_venv_auto_activate)\\b'

# Show active key bindings
bindkey | less
```

## Completion, Suggestions, and Editing Keys

| Key | Action |
|---|---|
| `Tab` | Completion (`expand-or-complete`; `fzf-tab` adds fuzzy selection UI) |
| `Shift+Tab` | Reverse completion |
| `Up` / `Down` | Sticky prefix history search (`Down` cycles path completions when current argument is path-like) |
| `Ctrl+P` / `Ctrl+N` | Sticky prefix history search |
| `Right Arrow` / `End` | Accept full autosuggestion |
| `Ctrl+Right` / `Alt+F` | Accept one word from autosuggestion |
| `Ctrl+Space` | Accept autosuggestion (`Ctrl+@` is also bound for tmux terminals) |
| `Ctrl+Z` | Undo last command-line edit |

## Navigation and File Shortcuts

| Shortcut | Expands to / Does |
|---|---|
| `cls` | `clear` |
| `..` / `...` / `....` | Jump up 1 / 2 / 3 directories |
| `z PATTERN` | Jump to most-used directory matching pattern (zoxide, if installed) |
| `zi` | Interactive directory picker with zoxide + fzf |
| `ls` | Uses `lsd` when installed; otherwise system `ls` |
| `l` | `lsd -l` when available; otherwise `ls -lFh` |
| `la` | `lsd -la` when available; otherwise `ls -lAFh` |
| `ll` | `lsd -lah` when available; otherwise `ls -lAh` (GNU: + `--group-directories-first --color=auto`) |
| `lt` | `tree -L 2` |
| `ldot` | `ls -ld .*` |
| `cat` | Uses `bat`/`batcat` plain mode when available |
| `catt` | Full `bat`/`batcat` view |
| `cp` / `mv` | Interactive copy/move (`-iv`) |
| `rm` | Safer remove (`rm -I`) |
| `mkdir` | Verbose parent-create (`mkdir -pv`) |
| `grep` | Colorized grep |
| `h` | `history` |
| `path` | Print one `PATH` entry per line |
| `myip` | Public IP (`curl ifconfig.me`) |
| `localip` | First local IP |
| `ssh HOST [ARGS...]` | Smart SSH: auto-timeout (10s), EC2 instance detection with `vm connect` offer, VPN retry fallback |
| `vm` | SSH to EC2 instance (auto-login, auto-start). Subcommands: `status`, `start`, `stop`, `ip` |
| `aws-login` | Refresh AWS SSO credentials (`aws sso login`) |
| `reload` | Reload `~/.zshrc` |
| `f` | Open current dir in system file manager |
| `mkcd NAME` | Create dir and enter it |
| `ff PATTERN` | Find files by name |
| `ftext PATTERN` | Search text (`rg` preferred) |
| `ports` | Show listening ports/processes |
| `ducks` | Top directory sizes |
| `c` | Opens `cursor` or `code` if installed |

## Git Shortcuts

`git` plugin from Oh My Zsh is enabled, plus custom helpers below.

### Custom Git Helpers in `.zshrc.template.sh`

| Shortcut | Does |
|---|---|
| `glog` | `git log --oneline --decorate --graph` |
| `glp` | Pretty graph log with relative date + author |
| `cdg` | `cd` to repo root (or stay in current dir if not in repo) |
| `lg` | Open `lazygit` TUI (if installed) |
| `gbr` | Fuzzy branch switcher (uses `fzf`) |
| `branch_bye` | Switch to main/default branch and delete current branch |
| `pr` | Open GitHub PR page or GitLab MR page for current branch |

### Common Oh My Zsh Git Aliases

| Shortcut | Expands to |
|---|---|
| `g` | `git` |
| `gst` | `git status` |
| `ga` / `gaa` | `git add` / `git add --all` |
| `gcmsg "msg"` | `git commit --message "msg"` |
| `gco` / `gcb` | `git checkout` / `git checkout -b` |
| `gsw` / `gswc` | `git switch` / `git switch --create` |
| `gcm` | `git checkout $(git_main_branch)` |
| `gd` / `gds` | `git diff` / `git diff --staged` (syntax-highlighted via `delta` if installed) |
| `gb` / `gba` / `gbd` | Local branches / all branches / delete branch |
| `glo` / `gloga` | One-line log / graph one-line log (all branches) |
| `gl` / `gpr` | `git pull` / `git pull --rebase` |
| `gp` / `gpf` | `git push` / force-with-lease push |
| `gsta` / `gsts` | Stash push / show stash patch |
| `grh` / `grhh` | `git reset` / `git reset --hard` |
| `grs` / `grst` | `git restore` / `git restore --staged` |
| `gsh` | `git show` |
| `git sw` / `git swc` | Global git aliases for `switch` / `switch --create` |

## Python and Virtualenv

| Shortcut | Does |
|---|---|
| `v` | Activate `.venv` or `venv` |
| `pyrun MOD` | `python -m MOD` |
| `pyserver` | `python -m http.server` |
| `psync` | `poetry install --sync` |
| `plock` | `poetry lock && poetry install` |

Behavior: on directory change, `.venv`/`venv` auto-activates if present, and auto-deactivates after leaving the project path.

## tmux Shortcuts

Shell helper:

| Command | Does |
|---|---|
| `tm [name]` | Create/attach tmux session (`main` by default) |

Managed tmux config (from `setup_zsh.sh`):

| Key / Setting | Action |
|---|---|
| `Ctrl+b` | tmux prefix (unchanged default) |
| `Prefix + r` | Reload `~/.tmux.conf` |
| `Prefix + [` | Enter copy mode (Vim keys enabled) |
| `Prefix + u` | Open URL picker — fzf menu of all URLs in current pane (reassembles wrapped/split URLs) |
| Mouse drag + release in pane | Select and copy to clipboard (no `Shift` needed) |
| `y` / `Enter` in copy mode | Copy to clipboard via `wl-copy` or `xclip` when available |
| Mouse mode | Enabled |
| Status bar | Top — session + hostname (left); CPU%, RAM, GPU% (if nvidia-smi), time (right); updates every 5s |
| Window/pane index | Starts at `1` |

Useful default tmux keys (not remapped):

| Key | Action |
|---|---|
| `Prefix + c` | New window |
| `Prefix + n` / `Prefix + p` | Next / previous window |
| `Prefix + %` | Split pane vertically |
| `Prefix + "` | Split pane horizontally |
| `Prefix + x` | Kill pane |
| `Prefix + z` | Toggle pane zoom |
| `Prefix + d` | Detach |

## FZF Keys

With fzf integration loaded:

| Key | Action |
|---|---|
| `Ctrl+R` | Fuzzy search shell history |
| `Ctrl+T` | Fuzzy insert file path |
| `Alt+C` | Fuzzy change directory |

This setup configures fzf to use `fd`/`fdfind`, include hidden files, and ignore `.git`.
