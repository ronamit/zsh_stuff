# zsh_stuff

Automation-first zsh environment setup for Ubuntu/Debian, plus utility scripts and guides.

## Quick Start

```bash
cd ~/zsh_stuff
bash setup_zsh.sh
```

Then: set terminal font to **Hack Nerd Font**, open a new terminal, and optionally run `p10k configure`.

Detailed usage & troubleshooting: [ZSH_SETUP_GUIDE.md](ZSH_SETUP_GUIDE.md)

## What `setup_zsh.sh` Does

- Installs zsh, Oh My Zsh, Powerlevel10k, and plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-history-substring-search`, `zsh-autocomplete`).
- Installs CLI tools via apt: fzf, fd, bat, ripgrep, tree, tmux, etc.
- Installs Hack Nerd Font.
- Configures tmux defaults, `.zshenv`, and `.bashrc` fallback.
- Backs up existing `~/.zshrc` and installs from `.zshrc.template`.
- Creates `~/.zshrc.local` for personal tokens/exports (never overwritten).
- Safe to re-run.

## What You Still Do Manually

1. Set terminal font to **Hack Nerd Font**.
2. Add personal exports/tokens to `~/.zshrc.local`.

## Files

| File | Purpose |
|------|---------|
| `setup_zsh.sh` | Installer/updater |
| `.zshrc.template` | Tracked shell config |
| `ZSH_SETUP_GUIDE.md` | Usage, key bindings, troubleshooting |
| `diagnose_ssh.sh` | SSH/VPN connection diagnostics |
| `clear-cursor-cache.sh` | Clear Cursor editor cache |
| `cursor-slow-cache-clear.md` | Cursor cache clearing guide |
| `yt-dlp-guide.md` | yt-dlp video download reference |
| `Setting_static_IP_on_Android_hotspot.md` | Static IP setup for Android hotspot |

## Updating

```bash
cd ~/zsh_stuff
git pull
bash setup_zsh.sh
```
