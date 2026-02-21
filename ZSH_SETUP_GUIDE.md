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

Full shortcut list (git aliases/functions, navigation, Python, tmux, fzf, keys):
[ZSH_SHORTCUTS_REFERENCE.md](ZSH_SHORTCUTS_REFERENCE.md)

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

**Ghost suggestions** (inline gray text): From `zsh-autosuggestions` using history (completion strategy disabled for responsiveness). Accept with `Right Arrow`, accept one word with `Ctrl+Right`.

**Interactive completion menu** (multiple candidates with highlighting): From `zsh-autocomplete` when installed. Current match is highlighted, items are colored by type (dirs in blue, etc.), and grouped under headers like `── directory ──`.

**Smart matching**: Completions are case-insensitive and support partial matching — typing `doc` matches `Documents`, `vid` matches `Videos`.

**Auto-cd**: Type a directory name without `cd` and press Enter to go there. Use `cd -1`, `cd -2` etc. to jump back to previous directories.

### Key bindings

| Key | With zsh-autocomplete | Without zsh-autocomplete |
|---|---|---|
| `Tab` / `Shift+Tab` | Next/prev completion | Next/prev completion |
| `Up` / `Down` | Menu/history (autocomplete) | Prefix history search |
| `Ctrl+P` / `Ctrl+N` | Prefix history search | Prefix history search |
| `Right Arrow` | Accept full autosuggestion | Accept full autosuggestion |
| `Ctrl+Right` | Accept one word of suggestion | Accept one word |
| `End` | Accept full autosuggestion | Accept full autosuggestion |
| `Ctrl+Space` | — | Accept autosuggestion |
| `Ctrl+Z` | Undo last edit | Undo last edit |

For all daily shortcuts (especially git workflows), see:
[ZSH_SHORTCUTS_REFERENCE.md](ZSH_SHORTCUTS_REFERENCE.md)

## tmux Defaults & Shortcuts

`setup_zsh.sh` writes a managed tmux block to `~/.tmux.conf`.

| Key / Command | Action |
|---|---|
| `tm` | Create/attach tmux session (`tm [name]`, default `main`) |
| `Ctrl+b` | tmux prefix key (default, unchanged) |
| `Prefix + r` | Reload `~/.tmux.conf` |
| `Prefix + [` | Enter copy mode (Vim keys enabled) |
| `y` in copy mode | Copy selection and send to clipboard (`wl-copy` or `xclip`) |
| `Enter` in copy mode | Copy selection and send to clipboard (`wl-copy` or `xclip`) |

Additional defaults: mouse mode on, history increased, window/pane numbering starts at `1`, status bar at top.

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
