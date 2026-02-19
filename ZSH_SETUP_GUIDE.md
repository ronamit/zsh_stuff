# ZSH Setup Guide (Ubuntu/Debian)

Automated zsh environment setup. Run the script; don't install components manually unless debugging.

## Quick Start

```bash
cd ~/zsh_stuff
bash setup_zsh.sh
```

After the script finishes:

1. Set your terminal font to **Hack Nerd Font**.
2. Review `~/.zshrc.local` and add any missing tokens/exports.
3. Open a new terminal (or `exec zsh`).
4. Optional: `p10k configure` to customize your prompt.

## What the Script Does

`setup_zsh.sh` handles the full baseline:

- Installs zsh, Oh My Zsh, Powerlevel10k.
- Installs plugins: `zsh-autosuggestions`, `zsh-history-substring-search`, `zsh-syntax-highlighting`, `zsh-autocomplete`.
- Installs CLI tools via apt (fzf, fd, bat, ripgrep, tree, tmux, etc.). Optional packages are best-effort.
- Installs Hack Nerd Font to `~/.local/share/fonts`.
- Adds a managed tmux config block to `~/.tmux.conf`.
- Backs up existing `~/.zshrc` and installs from `.zshrc.template`.
- Ensures `~/.zshenv` has `skip_global_compinit=1` (Ubuntu compatibility).
- Creates/preserves `~/.zshrc.local` for personal settings.
- Migrates likely token exports from old `~/.zshrc` to `~/.zshrc.local`.
- Sets zsh as default shell via `chsh` and adds a `.bashrc` fallback.
- Safe to re-run — skips already-installed components and creates fresh backups.

## Completions & Autosuggestions

**Ghost suggestions** (inline, one at a time): Controlled by `zsh-autosuggestions` with strategy `(history completion)`.

**Interactive completion menu** (multiple candidates): Provided by `zsh-autocomplete` when installed.

### Key bindings

| Key | With zsh-autocomplete | Without zsh-autocomplete |
|---|---|---|
| `Tab` / `Shift+Tab` | Next/prev completion | Next/prev completion |
| `Up` / `Down` | Menu/history (autocomplete) | Prefix history search |
| `Ctrl+P` / `Ctrl+N` | Prefix history search | Prefix history search |
| `Right Arrow` / `End` | Accept autosuggestion | Accept autosuggestion |
| `Ctrl+Space` | — | Accept autosuggestion |

## Where to Customize

| File | Purpose |
|---|---|
| `~/zsh_stuff/.zshrc.template` | Project defaults (tracked in git) |
| `~/.zshrc.local` | Personal tokens, exports, overrides (never overwritten) |

```bash
# Edit tracked defaults
nano ~/zsh_stuff/.zshrc.template

# Edit personal/local settings
nano ~/.zshrc.local

# Apply changes
source ~/.zshrc
```

## Updating

```bash
cd ~/zsh_stuff
git pull
bash setup_zsh.sh
```

## Troubleshooting

### Terminal still starts in bash

Close all terminals and reopen. Verify with:

```bash
getent passwd "$USER" | cut -d: -f7
```

If needed: `chsh -s "$(command -v zsh)"`. Note: SSH sessions may need a logout/login cycle.

### Prompt icons look broken

Set your terminal font to `Hack Nerd Font` and restart the terminal.

### Completions behave oddly

```bash
rm -f ~/.zcompdump && autoload -Uz compinit && compinit
```

### Syntax-highlighting widget warnings

This happens with `zsh-autocomplete` + `zsh-syntax-highlighting` on zsh < 5.9. The config automatically disables highlighting in that case. Upgrade to zsh 5.9+ for both plugins to coexist.

### Key bindings differ in your terminal

Check what sequence your terminal sends with `cat -v`, then bind that sequence in `.zshrc.template`.

## Roll Back

```bash
ls -1t ~/.zshrc.backup.*
cp ~/.zshrc.backup.<timestamp> ~/.zshrc
source ~/.zshrc
```

## References

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-autocomplete](https://github.com/marlonrichert/zsh-autocomplete)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
