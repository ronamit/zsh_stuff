# ZSH Setup Guide for Ubuntu

Complete guide to switch from bash to zsh with Oh My Zsh, Powerlevel10k theme, and powerful plugins.

---

## 🚀 Quick Start (5 Minutes)

### 1. Run Setup Script

```bash
cd ~/zsh_stuff
bash setup_zsh.sh
```

`setup_zsh.sh` now reads zsh config from `./.zshrc.template` (instead of an inline heredoc), so you can edit that template directly.

### 2. Install Configuration

```bash
cp ~/.zshrc ~/.zshrc.backup 2>/dev/null || true
cp ~/.zshrc.new ~/.zshrc
```

### 3. Change Default Shell

```bash
chsh -s $(which zsh)
# Enter your password when prompted
```

### 4. Configure Terminal Font

1. Terminal → **Edit** → **Preferences** → **Profiles** → **Text**
2. Enable **Custom font**
3. Select **Hack Nerd Font** (size **11** or **12**)

### 5. Restart Terminal

Close **ALL** terminal windows and reopen. Run `p10k configure` to customize your prompt.

**Done! 🎉** Your terminal now has auto-suggestions, syntax highlighting, fuzzy search, and more!

### Most Useful Features

**Fuzzy Search:**
- `Ctrl+R` - Search command history
- `Ctrl+T` - Search files
- `Alt+C` - Search directories

**Auto-suggestions:**
- Start typing and see suggestions in gray
- `Tab` - Normal completion menu
- `→` or `End` - Accept full suggestion
- `Ctrl+Space` - Accept full suggestion (explicit accept key)
- `↑` / `↓` - History substring search (can feel like autocomplete)

**Git Shortcuts:**
- `gst` - git status
- `gaa` - git add all
- `gcmsg 'msg'` - commit
- `gp` - git push

**Navigation:**
- `..` / `...` - Go up 1/2 directories
- `-` - Previous directory
- `z <pattern>` - Jump to frequently used directory

**Python:**
- `v` - Activate .venv
- Auto-activates when you `cd` into projects

---

## What the Setup Script Does Automatically

The `setup_zsh.sh` script performs all these steps for you:

### Core Components
1. **zsh** - The Z shell
2. **Oh My Zsh** - Framework for managing zsh configuration
3. **Powerlevel10k** - Modern, feature-rich prompt theme

### Plugins
4. **zsh-autosuggestions** - Fish-like autosuggestions as you type
5. **zsh-syntax-highlighting** - Syntax highlighting for commands
6. **zsh-history-substring-search** - Better history search

### Tools & Utilities
7. **fzf** - Fuzzy finder (Ctrl+R for history, Ctrl+T for files)
8. **fd** (fd-find) - Fast alternative to `find`
9. **bat** (batcat) - Better `cat` with syntax highlighting
10. **tree** - Directory tree viewer

### Fonts & Configuration
11. **fonts-powerline** - Base powerline fonts
12. **Hack Nerd Font** - Nerd Font with all icons for Powerlevel10k (same font used in VS Code/Cursor)
13. **Symlinks** - Creates `fd` and `bat` symlinks for Ubuntu's `fdfind` and `batcat`
14. **Auto-launch** - Adds zsh auto-launch to `.bashrc` (fixes terminal app issues)
15. **Template-driven zshrc** - Copies `.zshrc.template` to `~/.zshrc.new`

## Manual Setup (If You Prefer Step-by-Step)

### 1. Install zsh

```bash
sudo apt-get update
sudo apt-get install -y zsh
```

### 2. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3. Install Powerlevel10k Theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 4. Install Plugins

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
```

### 5. Install Recommended Tools

```bash
sudo apt-get install -y fzf fd-find bat tree

# Create symlinks for Ubuntu-specific names
mkdir -p ~/.local/bin
ln -sf $(which fdfind) ~/.local/bin/fd
ln -sf $(which batcat) ~/.local/bin/bat
```

### 6. Configure zsh

```bash
# Backup existing .zshrc if it exists
cp ~/.zshrc ~/.zshrc.backup 2>/dev/null || true

# Copy the new configuration
cp ~/.zshrc.new ~/.zshrc
```

### 7. Change Default Shell

```bash
chsh -s $(which zsh)
```

Then log out and log back in.

### 8. Install Hack Nerd Font (Recommended)

```bash
sudo apt-get install -y fonts-powerline wget unzip
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# Download Hack Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
unzip -o Hack.zip
rm Hack.zip

# Refresh font cache
fc-cache -fv

cd ~
```

**Configure Terminal to use Hack Nerd Font:**
1. Terminal → Edit → Preferences → Profiles → Text
2. Enable "Custom font"
3. Select "Hack Nerd Font" or "Hack Regular Nerd Font Complete"
4. Size: 11 or 12

This matches your VS Code/Cursor font for a consistent development environment!

## Optional Tools

### micro (Terminal text editor)

```bash
sudo apt-get install -y micro
```

### pyenv (Python version management)

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev

# Install pyenv
curl https://pyenv.run | bash
```

## Key Features of Your New Setup

### Directory Navigation
- `..` - Go up one directory
- `...` - Go up two directories
- `-` - Go to previous directory
- `z <pattern>` - Jump to frequently visited directory matching pattern
- `d` - Show directory stack

### File Operations
- `ll` - Detailed list view
- `lt` - Tree view
- `f` - Open current directory in file manager
- `ff <name>` - Find files by name
- `ftext <text>` - Find text in files

### Git Shortcuts
- `gst` - git status
- `gaa` - git add all
- `gcmsg` - git commit with message
- `gl` - git pull
- `gp` - git push
- `gco` - git checkout
- `cdg` - Go to git repository root
- `glp` - Pretty git log
- `pr` - Open PR page in browser

### Python Development
- `v` - Activate .venv in current directory
- `pyrun <module>` - Run Python module
- Auto-activation of virtualenvs when entering project directories

### FZF Shortcuts
- `Ctrl+R` - Fuzzy search command history
- `Ctrl+T` - Fuzzy search files
- `Alt+C` - Fuzzy search directories

### Autosuggestions
- Type a command and see suggestions from history in gray
- `Tab` - Normal completion (`expand-or-complete`)
- `→` (right arrow) - Accept full suggestion (`forward-char` at end-of-line)
- `End` - Accept full suggestion (`end-of-line` at end-of-line)
- `Ctrl+Space` - Accept full suggestion (`autosuggest-accept`)
- `↑` / `↓` - History substring search
- Optional: map `↓` to `autosuggest-accept` if you prefer full accept on Down Arrow

## Configuration Tips

### Customize Powerlevel10k

Run the configuration wizard anytime:

```bash
p10k configure
```

### Edit Your Configuration

```bash
# Open in your preferred editor
micro ~/.zshrc
# or
nano ~/.zshrc

# Reload after changes
source ~/.zshrc
# or
reload
```

### Add Custom Aliases

Add your custom aliases and functions to the end of `~/.zshrc`.

## Troubleshooting

### Terminal Still Opens Bash Instead of Zsh

If your terminal app still opens bash after running `chsh`:

1. **Verify the default shell was changed:**
   ```bash
   grep $USER /etc/passwd | tail -1
   # Should end with /usr/bin/zsh
   ```

2. **The setup script already added auto-launch to .bashrc**, so just close ALL terminal windows and reopen. The terminal will start bash briefly, then immediately switch to zsh.

3. **If that doesn't work**, manually add this to the end of `~/.bashrc`:
   ```bash
   # Auto-launch zsh
   if [ -t 1 ] && command -v zsh >/dev/null 2>&1; then
       export SHELL=$(which zsh)
       exec zsh
   fi
   ```

### Symbols/Icons Not Displaying (Boxes or Question Marks)

1. **Install Hack Nerd Font** (the setup script does this automatically)
2. **Configure your terminal** to use the font:
   - Terminal → Edit → Preferences → Profiles → Text
   - Enable "Custom font"
   - Select "Hack Nerd Font" or "Hack Regular Nerd Font Complete" size 11-12
3. **Close all terminals and reopen**
4. Test with: `echo "\ue0b0 \uf526 \ue0a0 \uf418"`

**Note:** This is the same font used in VS Code/Cursor, so your terminal and editor will have a consistent look!

### Theme Not Loading

Make sure your terminal supports 256 colors and has a compatible font installed. Powerlevel10k will prompt you to install recommended fonts during `p10k configure`.

### Slow Startup

Run the profiler to identify slow components:

```bash
# Uncomment the zprof lines in ~/.zshrc
# Then restart terminal and check output
```

### Completions Not Working

Rebuild the completion cache:

```bash
rm -f ~/.zcompdump
compinit
```

### Autosuggestion Keys Don’t Match This Guide

Terminal emulators can send different key codes, so `→`, `Ctrl+Space`, `End`, `↑`, and `↓` may behave differently from one machine to another.

Use this default mapping (already in `setup_zsh.sh`):

```zsh
# History search with arrows (terminfo first for tmux compatibility)
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# Completion + autosuggest accept
bindkey '^I' expand-or-complete
bindkey '^ ' autosuggest-accept
bindkey '^@' autosuggest-accept
bindkey '^[[C' forward-char
bindkey '^[OC' forward-char
bindkey '^[[F' end-of-line
bindkey '^[OF' end-of-line
# bindkey '^[[B' autosuggest-accept  # optional: Down Arrow accepts full suggestion
```

If a key still behaves unexpectedly, run `cat -v`, press that key, then use the printed sequence in `bindkey`.

### Virtual Environment Not Auto-Activating

The smart venv activation looks for `.venv` or `venv` directories. Make sure your virtual environment follows this naming convention.

## Reverting to Bash

If you want to switch back to bash:

```bash
chsh -s $(which bash)
```

Then log out and log back in.

## Additional Resources

- [Oh My Zsh Documentation](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k Documentation](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [FZF Documentation](https://github.com/junegunn/fzf)

## Quick Reference Card

Print this section or keep it handy while you learn zsh!

### Essential Shortcuts
- `Ctrl+R` - Fuzzy search command history (FZF)
- `Ctrl+T` - Fuzzy search files (FZF)
- `Alt+C` - Fuzzy search directories (FZF)
- `Tab` - Completion
- `→` / `End` - Accept full autosuggestion
- `Ctrl+Space` - Accept full autosuggestion
- `↑` / `↓` - History substring search

### Directory Navigation
- `..` / `...` / `....` - Go up 1/2/3 directories
- `-` - Previous directory
- `z <pattern>` - Jump to frequently visited directory
- `d` - Show directory stack
- `cdg` - Go to git repository root

### File Operations
- `ll` - Detailed list view
- `lt` - Tree view
- `f` - Open current directory in file manager
- `ff <name>` - Find files by name
- `ftext <text>` - Search text in files

### Git Shortcuts
- `gst` - git status
- `gaa` - git add all
- `gcmsg 'message'` - git commit
- `gl` - git pull
- `gp` - git push
- `gco <branch>` - git checkout
- `glp` - Pretty git log
- `gbr` - Interactive branch switcher (FZF)
- `pr` - Open PR page in browser
- `branch_bye` - Delete current branch, return to main

### Python Development
- `v` - Activate .venv
- `pyrun <module>` - Run Python module
- `psync` - Poetry sync
- `plock` - Poetry lock and install

### Connectivity & Utilities
- `vpn-connect` - Connect VPN (`~/vpn/vpn-connect.sh`)
- `vpn-status` - Check VPN status
- `vpn-disconnect` - Disconnect VPN
- `localip` - Show local LAN IP
- `myip` - Show public IP
- `ssha` - Add an SSH key to ssh-agent
- `ssha-default` - Add `~/.ssh/id_rsa` to ssh-agent

### Shell Management
- `reload` - Reload .zshrc
- `cc` - Clear terminal screen
- `cls` - Alternate clear shortcut
- `h` - Show shell history
- `path` - Print PATH one entry per line
- `tm` - Attach/create tmux session `main`
- `tm <name_or_number>` - Attach/create named tmux session (example: `tm 0`)
- `alias` - Show all aliases
- `p10k configure` - Reconfigure theme

## Next Steps

1. Explore the available aliases: type `alias` to see all
2. Learn FZF shortcuts (Ctrl+R is amazing!)
3. Customize the theme with `p10k configure`
4. Add your own custom functions and aliases to the end of `~/.zshrc`
5. Enjoy your new shell! 🎉
