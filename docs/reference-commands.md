# X Window System - Reference Commands Guide

## Quick Command Reference

This guide provides a comprehensive reference of all commands covered in the X Window System labs.

## Table of Contents
- [Basic X Server Commands](#basic-x-server-commands)
- [Display Manager Commands](#display-manager-commands)
- [Configuration Commands](#configuration-commands)
- [Troubleshooting Commands](#troubleshooting-commands)
- [Font Management Commands](#font-management-commands)
- [Remote X Access Commands](#remote-x-access-commands)
- [Performance Monitoring Commands](#performance-monitoring-commands)
- [Emergency Recovery Commands](#emergency-recovery-commands)

## Basic X Server Commands

### Starting and Stopping X Server
```bash
# Start X server manually
startx

# Start X server with specific configuration
startx -- -config /path/to/xorg.conf

# Start X server on specific display
X :1

# Stop X server
sudo pkill X

# Stop display manager
sudo systemctl stop display-manager

# Start display manager
sudo systemctl start display-manager

# Restart display manager
sudo systemctl restart display-manager
```

### X Server Information
```bash
# Check X server version
X -version

# Check if X server is running
ps aux | grep X | grep -v grep

# Check X server process details
pgrep -fl X

# Show X server capabilities
xdpyinfo

# Check current display
echo $DISPLAY

# Test X server access
xset q
```

## Display Manager Commands

### Managing Display Managers
```bash
# Check current display manager
cat /etc/X11/default-display-manager

# Check available display managers
ls -la /usr/sbin/*dm

# Switch display manager (Debian/Ubuntu)
sudo dpkg-reconfigure lightdm
sudo dpkg-reconfigure gdm3

# Set display manager manually
echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager

# Check display manager status
systemctl status display-manager

# List display manager services
systemctl list-units | grep -E "(gdm|lightdm|sddm|xdm)"
```

### Display Manager Configuration
```bash
# Configure LightDM
sudo nano /etc/lightdm/lightdm.conf

# Configure GDM3
sudo nano /etc/gdm3/custom.conf

# Configure LightDM greeter
sudo nano /etc/lightdm/lightdm-gtk-greeter.conf

# Set GDM banner
sudo -u gdm dbus-launch gsettings set org.gnome.login-screen banner-message-enable true
sudo -u gdm dbus-launch gsettings set org.gnome.login-screen banner-message-text "Message"
```

## Configuration Commands

### X Server Configuration
```bash
# Generate X configuration
sudo X -configure

# Test X configuration
sudo X -config /path/to/xorg.conf -retro

# Backup configuration
sudo cp /etc/X11/xorg.conf /etc/X11/xorg.conf.backup

# Edit X configuration
sudo nano /etc/X11/xorg.conf

# Check configuration syntax (test startup)
sudo X -config /etc/X11/xorg.conf :99 &
sudo pkill -f "X.*:99"
```

### Runlevel and Target Management
```bash
# Check current runlevel (SysV)
runlevel
who -r

# Check current systemd target
systemctl get-default

# Set graphical target as default
sudo systemctl set-default graphical.target

# Set multi-user target as default
sudo systemctl set-default multi-user.target

# Switch to text mode temporarily
sudo systemctl isolate multi-user.target

# Switch to graphical mode temporarily
sudo systemctl isolate graphical.target

# Switch to single-user mode
sudo systemctl isolate rescue.target
```

## Troubleshooting Commands

### Log Analysis
```bash
# View X server log
sudo tail -f /var/log/Xorg.0.log

# Check for errors in X log
sudo grep -E "(EE|Fatal)" /var/log/Xorg.0.log

# Check for warnings in X log
sudo grep "^(WW)" /var/log/Xorg.0.log

# View all log markers
grep -E "^\(II\)|^\(WW\)|^\(EE\)|^\(\*\*\)|^\(\+\+\)|^\(--\)" /var/log/Xorg.0.log

# Check systemd journal for display manager
journalctl -u display-manager -n 20

# Monitor logs in real-time
sudo journalctl -f -u display-manager
```

### Hardware Detection
```bash
# List video hardware
lspci | grep -i vga
lspci | grep -i display

# Check loaded kernel modules
lsmod | grep -E "(drm|video|fb)"

# List available X drivers
ls -la /usr/lib/xorg/modules/drivers/

# Check input devices
ls -la /dev/input/
cat /proc/bus/input/devices
```

### Alternative Console Access
```bash
# Switch to virtual console
Ctrl+Alt+F1  # Console 1
Ctrl+Alt+F2  # Console 2
Ctrl+Alt+F6  # Console 6

# Switch back to X server
Ctrl+Alt+F7  # or F1 depending on system

# Access via SSH
ssh -X username@hostname

# Boot in single-user mode (GRUB)
# Add to kernel line: single or 1
```

## Font Management Commands

### FontConfig Commands
```bash
# List all fonts
fc-list

# List font families
fc-list : family | sort | uniq

# Search for specific font
fc-list | grep "font-name"

# Test font matching
fc-match "serif"
fc-match "sans-serif"
fc-match "monospace"

# Show font information
fc-query /path/to/font.ttf

# List font directories
fc-list -d

# Show configuration files
fc-conflist

# Rebuild font cache
fc-cache -f -v

# Rebuild user font cache
fc-cache -f ~/.fonts

# Check font cache status
fc-cache -v
```

### Font Installation
```bash
# Install system-wide fonts
sudo cp fonts/* /usr/share/fonts/truetype/custom/
sudo fc-cache -f -v

# Install user fonts
mkdir -p ~/.fonts
cp fonts/* ~/.fonts/
fc-cache -f ~/.fonts

# Install font packages
sudo apt-get install fonts-liberation
sudo apt-get install fonts-dejavu
sudo apt-get install fonts-noto
```

### Legacy Font Commands
```bash
# Check X server font path (if X running)
xset q | grep -A 10 "Font Path"

# Add font path to X server
xset +fp /path/to/fonts

# Remove font path from X server
xset -fp /path/to/fonts

# Rehash fonts in X server
xset fp rehash

# List X11 fonts (legacy)
xlsfonts | head -20
```

## Remote X Access Commands

### SSH X11 Forwarding
```bash
# Connect with X11 forwarding
ssh -X username@hostname

# Connect with trusted X11 forwarding
ssh -Y username@hostname

# Connect with compression
ssh -XC username@hostname

# Test X11 forwarding
ssh -X username@hostname xterm

# Check X11 forwarding status
echo $DISPLAY
xset q
```

### SSH Configuration
```bash
# Enable X11 forwarding in SSH config
echo "X11Forwarding yes" | sudo tee -a /etc/ssh/sshd_config

# Configure X11 display offset
echo "X11DisplayOffset 10" | sudo tee -a /etc/ssh/sshd_config

# Allow X11 forwarding from any host
echo "X11UseLocalhost no" | sudo tee -a /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart ssh

# Test SSH configuration
sshd -T | grep -i x11
```

### XDMCP Commands (Reference)
```bash
# Test XDMCP connection
X -query hostname :1

# Connect to XDMCP server
Xnest -query hostname :1

# Check XDMCP configuration (GDM)
grep -A 5 "\[xdmcp\]" /etc/gdm3/custom.conf

# Check XDMCP ports
ss -tuln | grep 177
```

## Performance Monitoring Commands

### System Performance
```bash
# Monitor X server process
ps aux | grep X
top -p $(pgrep X)
htop -p $(pgrep X)

# Check X server memory usage
ps -o pid,vsz,rss,pcpu,pmem,comm -p $(pgrep X)

# Monitor system resources
vmstat 1
iostat 1
free -h
```

### Graphics Performance
```bash
# Check OpenGL information
glxinfo | grep -E "OpenGL|GLX"

# Test OpenGL performance
glxgears

# Check graphics hardware acceleration
glxinfo | grep "direct rendering"

# Display information
xrandr
xdpyinfo | grep -E "dimensions|resolution|depth"

# Check video memory
lspci -v | grep -A 20 VGA
```

### Network Performance (Remote X)
```bash
# Monitor network usage
iftop
nethogs
ss -tuln

# Test X11 forwarding performance
time ssh -X hostname xterm -e exit

# Check SSH connection compression
ssh -v hostname 2>&1 | grep compression
```

## Emergency Recovery Commands

### Quick Recovery
```bash
# Kill all X processes
sudo pkill X
sudo pkill gdm
sudo pkill lightdm

# Remove problematic configuration
sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.broken

# Generate new configuration
sudo X -configure
sudo cp xorg.conf.new /etc/X11/xorg.conf

# Use VESA driver fallback
sudo sed -i 's/Driver.*/Driver "vesa"/' /etc/X11/xorg.conf

# Reset to auto-configuration
sudo rm /etc/X11/xorg.conf
```

### System Recovery
```bash
# Boot in single-user mode (add to kernel line in GRUB)
single
1
init=/bin/bash

# Change to text mode
sudo systemctl set-default multi-user.target
sudo reboot

# Reset display manager
echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager
sudo systemctl restart display-manager

# Restore from backup
sudo cp /etc/X11/xorg.conf.backup /etc/X11/xorg.conf
```

### File Recovery
```bash
# Restore configuration backups
sudo cp /etc/X11/xorg.conf.backup /etc/X11/xorg.conf
sudo cp /etc/X11/default-display-manager.backup /etc/X11/default-display-manager

# Reset user session
rm ~/.xsession-errors
rm -rf ~/.cache/sessions
rm -rf ~/.config/fontconfig

# Clear font cache
fc-cache -f -v
```

## Diagnostic Commands

### Complete System Check
```bash
# X Window system status check script
#!/bin/bash

echo "=== X Window System Diagnostic ==="
echo "Date: $(date)"
echo ""

echo "=== Basic Information ==="
echo "X Server Version: $(X -version 2>&1 | head -1)"
echo "Display Manager: $(basename $(cat /etc/X11/default-display-manager 2>/dev/null))"
echo "Current Target: $(systemctl get-default)"
echo "Display Manager Status: $(systemctl is-active display-manager)"

echo ""
echo "=== Process Information ==="
ps aux | grep -E "X|gdm|lightdm|sddm" | grep -v grep

echo ""
echo "=== Configuration Files ==="
echo "xorg.conf exists: $([ -f /etc/X11/xorg.conf ] && echo Yes || echo No)"
echo "Font count: $(fc-list | wc -l)"

echo ""
echo "=== Hardware Information ==="
lspci | grep -i vga

echo ""
echo "=== Log Errors ==="
sudo grep -c "^(EE)" /var/log/Xorg.0.log 2>/dev/null || echo "No log file"

echo ""
echo "=== Display Information ==="
echo "DISPLAY: $DISPLAY"
if [ -n "$DISPLAY" ]; then
    xrandr 2>/dev/null | head -5 || echo "Cannot access display"
fi
```

## Environment Variables

### Important X Window Environment Variables
```bash
# Display specification
export DISPLAY=:0.0          # Local display 0, screen 0
export DISPLAY=hostname:10.0  # Remote display

# X11 authentication
export XAUTHORITY=~/.Xauthority

# Font configuration
export FONTCONFIG_PATH=/etc/fonts

# X11 library path
export LD_LIBRARY_PATH=/usr/lib/xorg

# Check current environment
env | grep -E "(DISPLAY|X|FONT)"
```

## Common File Locations

### Configuration Files
```bash
# X server configuration
/etc/X11/xorg.conf
/etc/X11/xorg.conf.d/*.conf

# Display manager configurations
/etc/X11/default-display-manager
/etc/lightdm/lightdm.conf
/etc/gdm3/custom.conf
/etc/sddm.conf

# Font configurations
/etc/fonts/fonts.conf
~/.config/fontconfig/fonts.conf
```

### Log Files
```bash
# X server logs
/var/log/Xorg.0.log
/var/log/Xorg.1.log

# Display manager logs
journalctl -u display-manager

# User session errors
~/.xsession-errors
```

### Font Directories
```bash
# System font directories
/usr/share/fonts/
/usr/local/share/fonts/
/etc/X11/fonts/

# User font directory
~/.fonts/
~/.local/share/fonts/
```

## Keyboard Shortcuts

### Virtual Console Switching
```bash
Ctrl+Alt+F1-F6    # Switch to virtual consoles
Ctrl+Alt+F7       # Return to X session (may vary)
Alt+F1-F6         # Switch between virtual consoles (when in console)
```

### X Window Emergency
```bash
Ctrl+Alt+Backspace  # Kill X server (if enabled)
Ctrl+Alt+Delete     # System restart (if configured)
```

## Quick Troubleshooting Flowchart

```
X Server Won't Start?
├── Check logs: tail /var/log/Xorg.0.log
├── Look for (EE) errors
├── Hardware issue?
│   ├── Use VESA driver
│   └── Check lspci | grep -i vga
├── Configuration issue?
│   ├── Remove xorg.conf
│   ├── Generate new: X -configure
│   └── Test: X -config xorg.conf.new
├── Permission issue?
│   ├── Check file ownership
│   └── Verify user groups
└── Font issue?
    ├── Check font paths
    └── Rebuild cache: fc-cache -f -v
```

---

**Keep this reference handy during X Window system administration!** 📚

This guide covers all commands from Labs 1-4 and provides quick solutions for common scenarios.