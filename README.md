# zsh_stuff

Automation-first zsh environment setup for Ubuntu/Debian.

Detailed usage and troubleshooting: [ZSH_SETUP_GUIDE.md](ZSH_SETUP_GUIDE.md)

## Quick Start

```bash
cd ~/zsh_stuff
bash setup_zsh.sh
source ~/.zshrc
```

Optional prompt wizard:

```bash
p10k configure
```

## What `setup_zsh.sh` Does Automatically

- Installs and configures `zsh`, Oh My Zsh, and Powerlevel10k.
- Installs plugins:
  - `zsh-autosuggestions`
  - `zsh-history-substring-search`
  - `zsh-syntax-highlighting`
  - `zsh-autocomplete` (combined history/files/options menu)
- Installs required/recommended CLI tools via `apt` (best-effort for optional packages).
- Installs Hack Nerd Font and refreshes font cache.
- Adds or updates a managed tmux defaults block in `~/.tmux.conf`.
- Backs up existing `~/.zshrc` and installs from `.zshrc.template`.
- Creates or preserves `~/.zshrc.local` and migrates likely token exports when possible.
- Attempts to set default shell to zsh and adds a `.bashrc` fallback auto-launch.
- Creates Ubuntu compatibility symlinks (`fd` for `fdfind`, `bat` for `batcat`) when needed.

## What You Still Need to Do

- Set terminal font to `Hack Nerd Font` in your terminal profile.
- Review and maintain personal secrets/exports in `~/.zshrc.local`.
- Open a new terminal or run `source ~/.zshrc` after changes.

## Key Files

- `setup_zsh.sh` - installer and updater.
- `.zshrc.template` - tracked default shell configuration.
- [ZSH_SETUP_GUIDE.md](ZSH_SETUP_GUIDE.md) - practical usage + troubleshooting.
- `diagnose_ssh.sh` - SSH/VPN diagnostics helper.

## Updating Later

```bash
cd ~/zsh_stuff
git pull
bash setup_zsh.sh
```

## Remote SSH (Optional)

For work VPN/SSH workflows, use:

- `~/vpn/vpn-connect.sh`
- `~/vpn/vpn-status.sh`
- `bash ~/zsh_stuff/diagnose_ssh.sh`
