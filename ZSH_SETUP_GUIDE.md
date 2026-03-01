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
- Installs plugins: `zsh-autosuggestions`, `zsh-history-substring-search`, `zsh-syntax-highlighting`, `fzf-tab`.
- Installs CLI tools via apt (fzf, fd, bat, ripgrep, tree, tmux, lsd, etc.). Optional packages are best-effort.
- Installs Hack Nerd Font to `~/.local/share/fonts`.
- Adds a managed tmux config block to `~/.tmux.conf`.
- Backs up existing `~/.zshrc` to `~/.zsh_backups/` and installs from `.zshrc.template.sh`.
- Ensures `~/.zshenv` has `skip_global_compinit=1` (Ubuntu compatibility).
- Sets global git aliases: `git sw` (`switch`) and `git swc` (`switch --create`).
- Creates/preserves `~/.zshrc.local` for personal settings.
- Migrates likely token exports from old `~/.zshrc` to `~/.zshrc.local`.
- Sets zsh as default shell via `chsh` and adds a `.bashrc` fallback.
- Safe to re-run — skips already-installed components and creates fresh backups.

## Completions & Autosuggestions

**Ghost suggestions** (inline gray text): From `zsh-autosuggestions`, shown live while you type (history first, then completion fallback). Accept with `Right Arrow`, accept one word with `Ctrl+Right`.

**Interactive completion menu** (multiple candidates with fuzzy selection): From `fzf-tab` on `Tab`, backed by zsh completion.

**Live path candidates while typing**: For `cd`/path-oriented commands, the completion list appears as you type (without pressing `Tab`). Toggle with `ZSH_AUTOLIST_ON_TYPE` (`1` on, `0` off; default `1`).
For bare `cd `, auto-open is gated by `ZSH_AUTOLIST_CD_EMPTY_MAX` (default `20`) so it opens early only when candidate count is small.

**Smart matching**: Completions are case-insensitive and support partial matching — typing `doc` matches `Documents`, `vid` matches `Videos`.

**Auto-cd**: Type a directory name without `cd` and press Enter to go there. Use `cd -1`, `cd -2` etc. to jump back to previous directories.

### Key bindings

| Key | Action |
|---|---|
| `Tab` / `Shift+Tab` | Next/prev completion |
| `Up` / `Down` | Prefix history search |
| `Ctrl+P` / `Ctrl+N` | Prefix history search |
| `Right Arrow` | Accept full autosuggestion |
| `Ctrl+Right` | Accept one word of suggestion |
| `End` | Accept full autosuggestion |
| `Ctrl+Space` | Accept autosuggestion |
| `Ctrl+Z` | Undo last edit |

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
| `~/zsh_stuff/.zshrc.template.sh` | Project defaults (tracked in git) |
| `~/.zshrc.local` | Personal tokens, exports, overrides (never overwritten) |

```bash
# Edit tracked defaults
nano ~/zsh_stuff/.zshrc.template.sh

# Edit personal/local settings
nano ~/.zshrc.local

# Optional: turn on live auto-list while typing
echo 'export ZSH_AUTOLIST_ON_TYPE=1' >> ~/.zshrc.local

# Optional: show `cd ` candidates earlier when there are few dirs
echo 'export ZSH_AUTOLIST_CD_EMPTY_MAX=20' >> ~/.zshrc.local

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

### Completion still feels slow in a huge repo

Disable `fzf-tab` temporarily to isolate the source:

```bash
mv ~/.oh-my-zsh/custom/plugins/fzf-tab ~/.oh-my-zsh/custom/plugins/fzf-tab.disabled
exec zsh
```

### Key bindings differ in your terminal

Check what sequence your terminal sends with `cat -v`, then bind that sequence in `.zshrc.template.sh`.

## Roll Back

```bash
ls -1t ~/.zsh_backups/.zshrc.backup.*
cp ~/.zsh_backups/.zshrc.backup.<timestamp> ~/.zshrc
source ~/.zshrc
```

## References

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [fzf-tab](https://github.com/Aloxaf/fzf-tab)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
