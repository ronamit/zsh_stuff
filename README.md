# zsh_stuff

Automation-first zsh environment setup for Ubuntu/Debian, plus utility scripts and guides.

## Quick Start

```bash
cd ~/zsh_stuff
bash setup_zsh.sh
```

Then: set terminal font to **Hack Nerd Font**, open a new terminal, and optionally run `p10k configure`.

Detailed usage & troubleshooting: [ZSH_SETUP_GUIDE.md](ZSH_SETUP_GUIDE.md)
Full shortcuts reference (git, tmux, Python, search, keys): [ZSH_SHORTCUTS_REFERENCE.md](ZSH_SHORTCUTS_REFERENCE.md)

## What `setup_zsh.sh` Does

- Installs zsh, Oh My Zsh, Powerlevel10k, and plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-history-substring-search`, `fzf-tab`).
- Installs CLI tools via apt: fzf, fd, bat, ripgrep, tree, tmux, lsd, etc.
- Installs Hack Nerd Font.
- Configures tmux defaults, `.zshenv`, and `.bashrc` fallback.
- Sets global git aliases: `git sw` (`switch`) and `git swc` (`switch --create`).
- Backs up existing `~/.zshrc` to `~/.zsh_backups/` and installs from `.zshrc.template.sh`.
- Creates `~/.zshrc.local` for personal tokens/exports (never overwritten).
- Safe to re-run.

## What You Still Do Manually

1. Set terminal font to **Hack Nerd Font**.
2. Add personal exports/tokens to `~/.zshrc.local`.

## Completion, Autosuggest, and Key Behavior

- `zsh-autosuggestions` shows inline ghost text from history (completion strategy disabled for responsiveness).
- `Right Arrow` or `End` accepts the full suggestion.
- `Ctrl+Right` (or `Alt+F`) accepts one word from the suggestion.
- `fzf-tab` provides interactive fuzzy completion on `Tab`.
- `Up` / `Down` and `Ctrl+P` / `Ctrl+N` run sticky prefix history search.
- `Ctrl+Space` accepts the autosuggestion (`^@` fallback is also bound for tmux terminals).

## tmux Defaults and Shortcuts

- `tm` opens or attaches a session: `tm [session-name]` (default: `main`).
- Prefix stays tmux default: `Ctrl+b`.
- `Prefix + r` reloads `~/.tmux.conf`.
- Mouse mode is enabled (pane selection, resize, scroll).
- Copy mode is Vim-style (`Prefix + [` to enter copy mode).
- In copy mode, `y` and `Enter` copy to system clipboard via `wl-copy` (Wayland) or `xclip` (X11) when available.

## Files

| File | Purpose |
|------|---------|
| `setup_zsh.sh` | Installer/updater |
| `.zshrc.template.sh` | Tracked shell config |
| `ZSH_SETUP_GUIDE.md` | Usage, key bindings, troubleshooting |
| `ZSH_SHORTCUTS_REFERENCE.md` | Full command/shortcut reference (git + shell + tmux + fzf) |
| `diagnose_ssh.sh` | SSH/VPN connection diagnostics |
| `it_support_message.txt` | IT ticket templates for VPN/SSH routing issues |
| `clear-cursor-cache.sh` | Clear Cursor editor cache |
| `cursor-slow-cache-clear.md` | Cursor cache clearing guide |
| `yt-dlp-guide.md` | yt-dlp video download reference |
| `Setting static IP on Android hotspot.md` | Static IP setup for Android hotspot |

## Updating

```bash
cd ~/zsh_stuff
git pull
bash setup_zsh.sh
```
