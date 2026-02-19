# ZSH Setup Guide (Ubuntu/Debian)

This guide is for the automated flow in this repo. Use `setup_zsh.sh`; do not manually install each component unless you are debugging.

## 1. Run Setup

```bash
cd ~/zsh_stuff
bash setup_zsh.sh
```

Notes:

- Requires `apt-get` (Ubuntu/Debian).
- Uses `sudo` for package operations.
- Safe to re-run; existing plugin/theme repos are reused.

## 2. What the Script Configures Automatically

`setup_zsh.sh` handles the full baseline setup:

- Installs: `zsh`, Oh My Zsh, Powerlevel10k.
- Installs plugins:
  - `zsh-autosuggestions`
  - `zsh-history-substring-search`
  - `zsh-syntax-highlighting`
  - `zsh-autocomplete`
- Installs required/recommended CLI packages via `apt` (optional packages are best-effort).
- Installs Hack Nerd Font to `~/.local/share/fonts` and refreshes font cache.
- Adds/updates a managed tmux block in `~/.tmux.conf`.
- Backs up existing `~/.zshrc` to `~/.zshrc.backup.<timestamp>`.
- Installs `~/.zshrc` from `./.zshrc.template`.
- Ensures `~/.zshenv` includes `skip_global_compinit=1` (Ubuntu compatibility for zsh-autocomplete).
- Creates/preserves `~/.zshrc.local` for personal settings.
- Attempts to migrate likely token exports from old `~/.zshrc` to `~/.zshrc.local`.
- Attempts `chsh -s "$(command -v zsh)"`.
- Adds `.bashrc` fallback auto-launch so terminals still enter zsh even when `chsh` is not applied.
- Skips package/download steps when tools, plugins, or fonts are already present.

## 3. Manual Steps After Setup

1. Set terminal font to `Hack Nerd Font`.
2. Review `~/.zshrc.local` and add any missing tokens/exports.
3. Apply config:

```bash
source ~/.zshrc
```

4. Optional prompt tuning:

```bash
p10k configure
```

## 4. Autosuggestions and Combined Completion

Current behavior from `.zshrc.template`:

- Ghost suggestion strategy: `ZSH_AUTOSUGGEST_STRATEGY=(history completion)`.
- Ghost suggestion length cap: `ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80`.
- Combined interactive menu (history + files + options) via `zsh-autocomplete` when installed.

Important distinction:

- Ghost text shows one inline suggestion at a time.
- The combined menu shows multiple candidates you can move through.

Default keys:

- With `zsh-autocomplete` installed:
  - completions show while typing.
  - `Tab`/`Shift+Tab`: next/previous completion.
  - `Up`/`Down`: handled by zsh-autocomplete (menu/history behavior can vary by terminal keycodes).
  - `Ctrl+P/Ctrl+N`: previous/next prefix history match.
  - `Right Arrow`/`End`: accept autosuggestion at end of line.
- Without `zsh-autocomplete`:
  - `Tab`: normal completion menu (`expand-or-complete`).
  - with completion menu open: `Tab`/`Shift+Tab` move next/previous option.
  - with completion menu open: `Up/Down` scroll options.
  - `Ctrl+Space`: accept autosuggestion.
  - `Up/Down`: prefix-only history search.

## 5. Where to Customize

- Project defaults (tracked): `~/zsh_stuff/.zshrc.template`
- Personal/local (not overwritten): `~/.zshrc.local`

Recommended workflow:

```bash
# edit tracked defaults
nano ~/zsh_stuff/.zshrc.template

# edit local secrets/personal overrides
nano ~/.zshrc.local

# apply current shell changes
source ~/.zshrc
```

## 6. Updating This Environment

When this repo changes:

```bash
cd ~/zsh_stuff
git pull
bash setup_zsh.sh
```

This reapplies managed config safely and creates a fresh `~/.zshrc` backup before replacing it.

## 7. Troubleshooting

### Terminal still starts in bash

- Close all terminal windows and reopen.
- Verify default shell:

```bash
getent passwd "$USER" | cut -d: -f7
```

- If needed, run manually:

```bash
chsh -s "$(command -v zsh)"
```

### Prompt icons look broken

- Confirm terminal profile font is `Hack Nerd Font`.
- Restart terminal after changing font.

### Completions behave oddly

Rebuild completion cache:

```bash
rm -f ~/.zcompdump
autoload -Uz compinit && compinit
```

### Powerlevel10k warning about console output and unhandled widgets

If you see warnings like:

- `zsh-syntax-highlighting: unhandled ZLE widget 'menu-search'`
- `zsh-syntax-highlighting: unhandled ZLE widget 'recent-paths'`

use the updated config from this repo and restart zsh:

```bash
cd ~/zsh_stuff
git pull
bash setup_zsh.sh
exec zsh
```

This setup sets `skip_global_compinit=1` in `~/.zshenv` and applies a
zsh-version-aware load order for `zsh-syntax-highlighting`:
- zsh `<5.9`: load before autocomplete widgets (compatibility mode).
- zsh `>=5.9`: load late (normal recommended order).

### Key bindings differ in your terminal

Check what key sequence your terminal sends:

```bash
cat -v
```

Press the key, then bind that sequence in `.zshrc.template` with `bindkey`.

## 8. Roll Back

Restore a backup if needed:

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
