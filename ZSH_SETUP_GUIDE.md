# ZSH Setup Guide (Linux + macOS)

Automated zsh environment setup for Linux and macOS. Run the script; don't install components manually unless debugging.

## Quick Start

```bash
cd ~/zsh_stuff
bash setup_zsh.sh
```

- **Linux**: requires `apt-get` (Ubuntu/Debian-family distros).
- **macOS**: requires [Homebrew](https://brew.sh).

After the script finishes:

1. Review `~/.zshrc.local` and add any missing tokens/exports.
2. Open a new terminal (or `exec zsh`).
3. Optional: `p10k configure` to customize your prompt.
4. Optional (for icon glyphs): `setup_zsh.sh` already installs the font files; set your terminal font to [Hack Nerd Font](https://www.nerdfonts.com/font-downloads) so icons render correctly.

Major setup actions performed by the installer:
- Installs zsh, Oh My Zsh, Powerlevel10k, and key plugins (`zsh-autosuggestions`, `zsh-history-substring-search`, `zsh-syntax-highlighting`, `fzf-tab`).
- Installs common CLI tools (`fzf`, `fd`, `bat`, `ripgrep`, `tree`, `tmux`, `lsd`, `zoxide`, `lazygit`, `fastfetch`, etc.).
- Configures `delta` as the git pager if installed — `git diff`, `git log -p`, and `git show` get syntax highlighting automatically.
- Installs Hack Nerd Font files.
- Applies managed tmux defaults in `~/.tmux.conf`, including a status bar (session name, CPU%, RAM, GPU% if nvidia-smi present, time).
- Installs [TPM](https://github.com/tmux-plugins/tpm) and tmux plugins: tmux-sensible, tmux-open, tmux-yank, tmux-resurrect.
- Creates `~/.local/bin/tmux-status` helper script for the status bar.
- Backs up and replaces your existing `~/.zshrc` with the project config, and preserves/creates `~/.zshrc.local`.
- Sets zsh as default shell (with `.bashrc` fallback) and adds global git aliases (`git sw`, `git swc`).

Full shortcut list (git aliases/functions, navigation, Python, tmux, fzf, keys):
[ZSH_SHORTCUTS_REFERENCE.md](ZSH_SHORTCUTS_REFERENCE.md)

## What the Script Does

`setup_zsh.sh` handles the full baseline:

- Installs zsh, Oh My Zsh, Powerlevel10k.
- Installs plugins: `zsh-autosuggestions`, `zsh-history-substring-search`, `zsh-syntax-highlighting`, `fzf-tab`.
- **Linux**: installs CLI tools via apt (fzf, fd, bat, ripgrep, tree, tmux, lsd, zoxide, lazygit, fastfetch, etc.). Optional packages are best-effort.
- **macOS**: installs CLI tools via Homebrew (same list).
- Configures `delta` as the git pager if installed — no command changes needed, it just replaces the pager for `git diff`, `git log -p`, `git show`.
- Installs Hack Nerd Font (Linux: `~/.local/share/fonts`; macOS: Homebrew cask or `~/Library/Fonts`).
- Adds a managed tmux config block to `~/.tmux.conf`, including a status bar with session name, CPU%, RAM, GPU% (if nvidia-smi present), and time.
- Creates `~/.local/bin/tmux-status` — the helper script powering the tmux status bar (works on Linux and macOS).
- Backs up your existing `~/.zshrc` to `~/.zsh_backups/` and replaces it from `.zshrc.template.sh`.
- Ensures `~/.zshenv` has `skip_global_compinit=1` (Ubuntu compatibility).
- Sets global git aliases: `git sw` (`switch`) and `git swc` (`switch --create`).
- Creates/preserves `~/.zshrc.local` for personal settings.
- Migrates likely token exports from old `~/.zshrc` to `~/.zshrc.local`.
- Sets zsh as default shell via `chsh` and adds a `.bashrc` fallback.
- Safe to re-run — skips already-installed components and creates fresh backups.

## Completions & Autosuggestions

**Ghost suggestions** (inline gray text): From `zsh-autosuggestions`, shown live while you type (history first, then completion fallback). Accept with `Right Arrow`, accept one word with `Ctrl+Right` (or `Alt+F`).

**Interactive completion menu** (multiple candidates with fuzzy selection): From `fzf-tab` on `Tab`, backed by zsh completion.

**Live path candidates while typing**: For `cd`/path-oriented commands, the completion list appears as you type (without pressing `Tab`). Toggle with `ZSH_AUTOLIST_ON_TYPE` (`1` on, `0` off; default `1`).
For bare `cd `, auto-open is gated by `ZSH_AUTOLIST_CD_EMPTY_MAX` (default `20`) so it opens early only when candidate count is small.

**Smart matching**: Completions are case-insensitive and support partial matching — typing `doc` matches `Documents`, `vid` matches `Videos`.

**Auto-cd**: Type a directory name without `cd` and press Enter to go there. Use `cd -1`, `cd -2` etc. to jump back to previous directories.

### Key bindings

| Key | Action |
|---|---|
| `Tab` / `Shift+Tab` | Next/prev completion |
| `Up` / `Down` | Prefix history search (`Down` cycles path completions when current argument is path-like) |
| `Ctrl+P` / `Ctrl+N` | Prefix history search |
| `Right Arrow` | Accept full autosuggestion |
| `Ctrl+Right` / `Alt+F` | Accept one word of suggestion |
| `End` | Accept full autosuggestion |
| `Ctrl+Space` | Accept autosuggestion (`Ctrl+@` fallback is also bound for tmux terminals) |
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
| `Prefix + u` | URL picker — fzf menu of all URLs in pane + scrollback (handles wrapped URLs) |
| `Prefix + [` | Enter copy mode (Vim keys enabled) |
| Mouse drag + release in pane | Select and copy to clipboard (no `Shift` needed) |
| `y` in copy mode | Copy selection and send to clipboard (`wl-copy` or `xclip`) |
| `Enter` in copy mode | Copy selection and send to clipboard (`wl-copy` or `xclip`) |
| `o` in copy mode | Open highlighted URL/file (tmux-open plugin) |
| `Ctrl+o` in copy mode | Open highlighted file in `$EDITOR` (tmux-open plugin) |
| `Prefix + Ctrl+s` | Save tmux session (tmux-resurrect) |
| `Prefix + Ctrl+r` | Restore tmux session (tmux-resurrect) |
| `Prefix + I` | Install new TPM plugins |
| `Prefix + U` | Update TPM plugins |

Additional defaults: mouse mode on, history increased, window/pane numbering starts at `1`, status bar at top, truecolor enabled (`RGB` with `Tc` compatibility), OSC 8 hyperlinks enabled, and passthrough allowed for compatible terminals/apps.

**Plugins** (managed by [TPM](https://github.com/tmux-plugins/tpm)): tmux-sensible (sensible defaults), tmux-open (open URLs/files from copy mode), tmux-yank (system clipboard integration), tmux-resurrect (save/restore sessions across reboots).

**Status bar** (top): left shows session name + hostname; right shows CPU%, RAM, GPU% (if `nvidia-smi` is available), and time. Updates every 5 seconds via `~/.local/bin/tmux-status`.

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

## Smart SSH Wrapper

`ssh` is wrapped in interactive shells with these features:

- **Auto-timeout**: Adds `ConnectTimeout=10` so SSH won't hang forever on unreachable hosts.
- **EC2 detection**: If the target matches your configured EC2 instance and SSH fails, shows the instance state and offers to run `vm connect` (auto-login, auto-start, SSH).
- **VPN retry**: For non-EC2 hosts, prompts whether to run `vpn-connect` and retries once.

## EC2 VM Helper (`vm` command)

One-command access to an AWS EC2 dev instance. Handles SSO login, instance start/stop, and SSH — no need to touch the AWS console.

### Setup

Requires the AWS CLI (`aws`). The `vm` command is only available when `aws` is installed.

**Step 1: Configure AWS SSO** (one-time, if your org uses SSO):

```bash
aws configure sso
```

You will need your SSO start URL (e.g. `https://your-org.awsapps.com/start`), region, account ID, and role name. This creates `~/.aws/config`.

**Step 2: Add instance config to `~/.zshrc.local`:**

```bash
export EC2_INSTANCE_ID="i-0abc123..."        # your instance ID (find in AWS console)
export EC2_REGION="us-east-2"                 # AWS region
export EC2_SSH_USER="ubuntu"                  # SSH username on the instance
export EC2_SSH_KEY="$HOME/.ssh/my-key.pem"    # path to your SSH key
export EC2_AWS_PROFILE="my-profile"           # AWS CLI profile name (optional)
```

**Step 3: Reload and test:**

```bash
source ~/.zshrc
vm status
```

If you just type `vm` without any config, it prints the setup instructions above.

### Usage

| Command | Action |
|---|---|
| `vm` | Check AWS creds (refresh if expired), start instance if stopped, SSH in |
| `vm status` | Show instance state and IP |
| `vm start` | Start the instance |
| `vm stop` | Stop the instance |
| `vm ip` | Print the public IP |
| `aws-login` | Refresh AWS SSO credentials (shortcut for `aws sso login`) |

### How it solves common problems

| Problem | What `vm` does |
|---|---|
| AWS SSO token expired | Automatically opens browser for SSO login |
| Instance is stopped | Starts it and waits for SSH to be ready |
| Forgot the IP | Looks it up via AWS API |
| SSH hangs (unreachable host) | `ssh` wrapper times out in 10s and offers `vm connect` |

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
# Linux
getent passwd "$USER" | cut -d: -f7

# macOS
dscl . -read "/Users/$USER" UserShell | awk '{print $2}'
```

If needed: `chsh -s "$(command -v zsh)"`. Note: SSH sessions may need a logout/login cycle.

### Prompt icons look broken

Set your terminal font to `Hack Nerd Font` (https://www.nerdfonts.com/font-downloads) and restart the terminal.

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

### Restore your previous `~/.zshrc` backup

```bash
ls -1t ~/.zsh_backups/.zshrc.backup.*
cp ~/.zsh_backups/.zshrc.backup.<timestamp> ~/.zshrc
exec zsh
```

### Switch default shell back to bash

```bash
chsh -s "$(command -v bash)"
exec bash
```

Then edit `~/.bashrc` and remove this block (added by `setup_zsh.sh`) if you do not want bash to auto-launch zsh:

```bash
# Auto-launch zsh if available (added by zsh_stuff setup)
if [ -t 1 ] && [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null 2>&1; then
    export SHELL=$(command -v zsh)
    exec zsh
fi
```

## References

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [fzf-tab](https://github.com/Aloxaf/fzf-tab)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
