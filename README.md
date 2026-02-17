# Setup Guides

**Quick navigation:**

- 🔐 **Remote SSH Setup** → See below
- 🐚 **ZSH Shell Setup** → [ZSH_SETUP_GUIDE.md](ZSH_SETUP_GUIDE.md)

---

# Remote SSH Setup - Quick Start

Setup remote development from your laptop to work desktop.

## ⚡ Prerequisites

1. **Desktop must be on VLAN 10** (IP: 10.10.x.x)
   - Check on desktop: `hostname -I`
   - If starts with 10.1.x.x → Contact IT: "Please move my desktop to VLAN 10"

2. **SSH server running on desktop:**
   ```bash
   sudo apt install openssh-server
   sudo systemctl enable --now ssh
   ```

## 🚀 Setup (5 minutes)

### 1. Connect VPN
```bash
~/vpn/vpn-connect.sh
```
Enter 2FA code when prompted.

### 2. Test connectivity
```bash
ping -c 3 10.10.XXX.XXX  # Replace with your desktop IP
```
**If ping fails** → Desktop on wrong VLAN, contact IT.

### 3. Generate SSH key (if needed)
```bash
# Check if you have one
ls ~/.ssh/id_ed25519

# If not, create:
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

### 4. Copy key to desktop
```bash
ssh-copy-id -i ~/.ssh/id_ed25519 <username>@10.10.XXX.XXX
```
Enter your desktop password once.

### 5. Create SSH config
```bash
nano ~/.ssh/config
```

Add (replace with your details):
```
Host work-desktop
    HostName 10.10.XXX.XXX
    User <your-username>
    IdentityFile ~/.ssh/id_ed25519
```

Save and set permissions:
```bash
chmod 600 ~/.ssh/config
```

### 6. Test connection
```bash
ssh work-desktop
```
Should connect without password! 🎉

## 💻 Use in Cursor/VSCode

1. Install **Remote - SSH** extension
2. `Ctrl+Shift+P` → **Remote-SSH: Connect to Host**
3. Select **work-desktop**
4. Open your code folders

## 🐛 Troubleshooting

### Connection times out
```bash
# Check VPN
~/vpn/vpn-status.sh

# Run diagnostics
bash ~/zsh_stuff/diagnose_ssh.sh
```

**Common issues:**
- VPN not connected → `~/vpn/vpn-connect.sh`
- Desktop on wrong VLAN (10.1.x.x) → Contact IT
- Desktop on WiFi (172.16.x.x) → Use Ethernet

### Permission denied
```bash
# Copy SSH key again
ssh-copy-id -i ~/.ssh/id_ed25519 <username>@<desktop-ip>
```

### VPN won't connect
- Make sure 2FA code is fresh (they expire in 30 seconds)
- Check logs: `tail -20 ~/vpn/vpn-connection.log`
- Reconnect: `~/vpn/vpn-disconnect.sh && ~/vpn/vpn-connect.sh`

## 📋 Daily Usage

```bash
# Connect VPN (do this first)
~/vpn/vpn-connect.sh

# SSH to desktop
ssh work-desktop

# Check VPN status
~/vpn/vpn-status.sh

# Disconnect VPN
~/vpn/vpn-disconnect.sh
```

## 🆘 Need Help?

1. Run diagnostics: `bash ~/zsh_stuff/diagnose_ssh.sh`
2. Check VPN guide: `cat ~/vpn/VPN-README.md`
3. Contact IT with details from diagnostic output

---

## IT Support Template

If you need to contact IT about VLAN:

> Hi IT,
>
> I need my desktop moved to VLAN 10 for VPN remote access.
> Current IP: 10.1.x.x (VLAN 1)
> Needed: 10.10.x.x (VLAN 10)
>
> Can you configure this when I'm in the office?
>
> Thanks!

---

**That's it! You're ready for remote development.** 🚀

For better terminal experience, see [ZSH_SETUP_GUIDE.md](ZSH_SETUP_GUIDE.md)
