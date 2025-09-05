# X Window System Troubleshooting Guide

## Overview

This guide provides systematic troubleshooting procedures for X Window system issues. It covers the most common problems encountered in Linux desktop environments and provides step-by-step solutions.

## Table of Contents

- [General Troubleshooting Methodology](#general-troubleshooting-methodology)
- [X Server Won't Start](#x-server-wont-start)
- [Display Issues](#display-issues)
- [Input Device Problems](#input-device-problems)
- [Font Issues](#font-issues)
- [Performance Problems](#performance-problems)
- [Remote X Access Issues](#remote-x-access-issues)
- [Emergency Recovery](#emergency-recovery)
- [Prevention and Maintenance](#prevention-and-maintenance)

## General Troubleshooting Methodology

### Step 1: Gather Information
```bash
# Check system status
systemctl status display-manager
ps aux | grep X | grep -v grep
echo $DISPLAY

# Check logs
sudo tail -50 /var/log/Xorg.0.log
journalctl -u display-manager -n 20

# Identify errors
sudo grep -E "(EE|Fatal)" /var/log/Xorg.0.log
sudo grep "^(WW)" /var/log/Xorg.0.log
```

### Step 2: Isolate the Problem
```bash
# Test with minimal configuration
sudo systemctl stop display-manager
sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
sudo systemctl start display-manager

# If that works, the problem is in xorg.conf
# If not, check hardware and drivers
```

### Step 3: Apply Solutions Incrementally
- Start with least invasive solutions
- Test each change before proceeding
- Document what works and what doesn't
- Keep backups of working configurations

## X Server Won't Start

### Symptoms
- Black screen on boot
- Display manager fails to start
- Error messages about X server failure
- System boots to console only

### Diagnostic Steps

1. **Check X server logs**:
   ```bash
   sudo tail -50 /var/log/Xorg.0.log
   sudo grep -E "(EE|Fatal)" /var/log/Xorg.0.log
   ```

2. **Verify X server executable**:
   ```bash
   which X
   X -version
   ```

3. **Check display manager status**:
   ```bash
   systemctl status display-manager
   journalctl -u display-manager
   ```

### Common Causes and Solutions

#### Configuration File Issues
```bash
# Problem: Invalid xorg.conf
# Solution: Remove or regenerate configuration
sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.broken
sudo X -configure
sudo cp xorg.conf.new /etc/X11/xorg.conf
sudo systemctl restart display-manager
```

#### Driver Problems
```bash
# Problem: Video driver not found
# Solution: Use VESA fallback driver
sudo nano /etc/X11/xorg.conf

# Edit Device section:
Section "Device"
    Identifier  "VideoCard"
    Driver      "vesa"
EndSection

sudo systemctl restart display-manager
```

#### Permission Issues
```bash
# Problem: Incorrect permissions
# Solution: Fix file permissions
sudo chmod 644 /etc/X11/xorg.conf
sudo chown root:root /etc/X11/xorg.conf
sudo chmod 755 /etc/X11
```

## Display Issues

### Black Screen with Cursor

#### Causes
- Window manager not starting
- Desktop environment failure
- Display timing issues

#### Solutions
```bash
# Test with basic window manager
sudo apt-get install openbox
echo "exec openbox-session" > ~/.xsession

# Check desktop environment logs
cat ~/.xsession-errors | tail -20

# Reset user configuration
mv ~/.config ~/.config.backup
mv ~/.cache ~/.cache.backup
```

### Wrong Resolution or Refresh Rate

#### Solutions
```bash
# Check available modes
xrandr

# Set resolution manually
xrandr --output VGA-1 --mode 1024x768

# Make permanent in xorg.conf
Section "Screen"
    Identifier    "Screen0"
    Device        "Card0"
    Monitor       "Monitor0"
    DefaultDepth  24
    SubSection "Display"
        Depth     24
        Modes     "1024x768" "800x600"
    EndSubSection
EndSection
```

### Monitor Not Detected

#### Solutions
```bash
# Force monitor detection
xrandr --output VGA-1 --auto
xrandr --output HDMI-1 --auto

# Use safe monitor configuration
Section "Monitor"
    Identifier   "Monitor0"
    HorizSync    28.0-64.0
    VertRefresh  43.0-60.0
EndSection
```

## Input Device Problems

### Keyboard Not Working

#### Diagnostic Steps
```bash
# Check input devices
ls -la /dev/input/
cat /proc/bus/input/devices

# Test keyboard in console
# Switch to VT1 with Ctrl+Alt+F1
```

#### Solutions
```bash
# Reconfigure keyboard
sudo dpkg-reconfigure keyboard-configuration

# Reset X input configuration
sudo rm /etc/X11/xorg.conf.d/*-keyboard.conf
sudo systemctl restart display-manager

# Manual keyboard configuration
Section "InputDevice"
    Identifier  "Keyboard0"
    Driver      "kbd"
    Option      "XkbLayout" "us"
EndSection
```

### Mouse Not Working

#### Solutions
```bash
# Check mouse detection
lsusb | grep -i mouse
dmesg | grep -i mouse

# Reset mouse configuration
Section "InputDevice"
    Identifier  "Mouse0"
    Driver      "mouse"
    Option      "Protocol" "auto"
    Option      "Device" "/dev/input/mice"
EndSection
```

## Font Issues

### Fonts Not Displaying

#### Symptoms
- Missing characters or boxes
- Applications fail to start with font errors
- Poor font rendering quality

#### Solutions
```bash
# Rebuild font cache
fc-cache -f -v

# Check font availability
fc-list | head -10

# Install basic fonts
sudo apt-get install fonts-liberation fonts-dejavu

# Check X server font configuration
Section "Files"
    FontPath     "catalogue:/etc/X11/fontpath.d"
    FontPath     "built-ins"
EndSection
```

### Font Rendering Issues

#### Solutions
```bash
# Configure font rendering
mkdir -p ~/.config/fontconfig
cat > ~/.config/fontconfig/fonts.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit mode="assign" name="antialias">
      <bool>true</bool>
    </edit>
    <edit mode="assign" name="hinting">
      <bool>true</bool>
    </edit>
    <edit mode="assign" name="hintstyle">
      <const>hintslight</const>
    </edit>
  </match>
</fontconfig>
EOF

fc-cache -f
```

## Performance Problems

### High CPU Usage

#### Diagnostic Steps
```bash
# Monitor X server process
top -p $(pgrep X)
ps aux | grep X

# Check for runaway processes
ps aux --sort=-%cpu | head -10
```

#### Solutions
```bash
# Reduce visual effects
# Disable compositing
# Use lightweight window manager

# Optimize X server configuration
Section "Device"
    Identifier  "VideoCard"
    Driver      "auto"
    Option      "AccelMethod" "none"    # Disable if causing issues
EndSection
```

### Memory Issues

#### Solutions
```bash
# Monitor memory usage
free -h
ps aux --sort=-%mem | head -10

# Restart X server periodically
sudo systemctl restart display-manager

# Reduce color depth
Section "Screen"
    Identifier    "Screen0"
    DefaultDepth  16    # Use 16-bit instead of 24/32
EndSection
```

## Remote X Access Issues

### SSH X11 Forwarding Not Working

#### Diagnostic Steps
```bash
# Check SSH configuration
grep X11 /etc/ssh/sshd_config

# Test X11 forwarding
ssh -X user@host xterm
echo $DISPLAY
```

#### Solutions
```bash
# Enable X11 forwarding in SSH
sudo nano /etc/ssh/sshd_config

# Add/uncomment these lines:
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost no

sudo systemctl restart ssh

# Test forwarding
ssh -X user@host
xauth list
xset q
```

### XDMCP Connection Issues

#### Solutions
```bash
# Configure XDMCP (GDM)
sudo nano /etc/gdm3/custom.conf

[xdmcp]
Enable=true
Port=177

# Configure firewall
sudo ufw allow 177/udp

# Test XDMCP
X -query server_ip :1
```

## Emergency Recovery

### Complete X System Failure

#### Recovery Steps
```bash
# Boot to single-user mode
# Add to kernel line in GRUB: single

# Or access via SSH/console
# Ctrl+Alt+F1 through F6

# Remove problematic configuration
sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.broken

# Reset display manager
echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager

# Reinstall X server if needed
sudo apt-get update
sudo apt-get install --reinstall xserver-xorg

# Reboot and test
sudo reboot
```

### Create Emergency Recovery Script
```bash
#!/bin/bash
# emergency-x-recovery.sh

echo "Emergency X Recovery Mode"

# Stop all X processes
sudo systemctl stop display-manager
sudo pkill X

# Backup current config
sudo cp /etc/X11/xorg.conf /etc/X11/xorg.conf.emergency.backup 2>/dev/null

# Create minimal safe configuration
cat | sudo tee /etc/X11/xorg.conf << 'EOF'
Section "Device"
    Identifier  "EmergencyCard"
    Driver      "vesa"
EndSection

Section "Monitor"
    Identifier   "EmergencyMonitor"
    HorizSync    28.0-64.0
    VertRefresh  43.0-60.0
EndSection

Section "Screen"
    Identifier    "EmergencyScreen"
    Device        "EmergencyCard"
    Monitor       "EmergencyMonitor"
    DefaultDepth  16
    SubSection "Display"
        Depth     16
        Modes     "800x600" "640x480"
    EndSubSection
EndSection
EOF

# Test configuration
sudo X -config /etc/X11/xorg.conf :99 &
sleep 3
if ps aux | grep -q "X.*:99"; then
    echo "Emergency config successful"
    sudo pkill -f "X.*:99"
    sudo systemctl start display-manager
else
    echo "Emergency config failed - removing xorg.conf"
    sudo rm /etc/X11/xorg.conf
    sudo systemctl start display-manager
fi
```

## Prevention and Maintenance

### Regular Maintenance Tasks

```bash
# Weekly checks
sudo grep -E "(EE|Fatal)" /var/log/Xorg.0.log | tail -10
systemctl status display-manager
df -h    # Check disk space

# Monthly tasks
sudo apt-get update && sudo apt-get upgrade
fc-cache -f -v    # Rebuild font cache
```

### Backup Important Configurations

```bash
#!/bin/bash
# backup-x-config.sh

BACKUP_DIR="/home/$USER/x-backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup configurations
sudo cp /etc/X11/xorg.conf "$BACKUP_DIR/" 2>/dev/null
cp /etc/X11/default-display-manager "$BACKUP_DIR/" 2>/dev/null
cp -r ~/.config/fontconfig "$BACKUP_DIR/" 2>/dev/null

echo "X configuration backed up to $BACKUP_DIR"
```

### Monitoring Scripts

```bash
#!/bin/bash
# x-monitor.sh - Monitor X Window system health

echo "=== X Window System Health Check ==="
echo "Date: $(date)"

# Check X server status
if systemctl is-active display-manager > /dev/null; then
    echo "Display Manager: RUNNING"
else
    echo "Display Manager: FAILED"
fi

# Check for recent errors
ERROR_COUNT=$(sudo grep -c "^(EE)" /var/log/Xorg.0.log)
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "X Server Errors: $ERROR_COUNT (check logs)"
else
    echo "X Server Errors: None"
fi

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "Disk Space: WARNING ($DISK_USAGE% full)"
else
    echo "Disk Space: OK ($DISK_USAGE% used)"
fi

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
echo "Memory Usage: $MEM_USAGE%"
```

## Troubleshooting Decision Tree

```
X Window Issue?
├── Won't Start?
│   ├── Check logs: /var/log/Xorg.0.log
│   ├── Test config: mv xorg.conf xorg.conf.backup
│   ├── Try VESA driver
│   └── Check permissions
├── Display Problems?
│   ├── Wrong resolution: Use xrandr
│   ├── Black screen: Check window manager
│   └── Monitor issues: Safe sync rates
├── Input Issues?
│   ├── Keyboard: Check /dev/input/, reconfigure
│   └── Mouse: Check USB, driver configuration
├── Font Problems?
│   ├── Missing fonts: Install packages, rebuild cache
│   └── Rendering: Configure fontconfig
└── Performance Issues?
    ├── High CPU: Check processes, disable effects
    └── Memory: Monitor usage, restart X server
```

## Quick Reference Commands

### Essential Diagnostics
```bash
sudo tail -50 /var/log/Xorg.0.log              # Check X server log
sudo grep -E "(EE|Fatal)" /var/log/Xorg.0.log  # Find critical errors
systemctl status display-manager               # Check DM status
ps aux | grep X | grep -v grep                 # Find X processes
xrandr                                          # Display information
fc-list | wc -l                               # Font count
```

### Quick Fixes
```bash
sudo systemctl restart display-manager         # Restart display manager
sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup  # Remove config
fc-cache -f -v                                # Rebuild font cache
Ctrl+Alt+F1                                   # Switch to console
```

### Emergency Commands
```bash
sudo pkill X                                  # Kill X server
sudo systemctl stop display-manager           # Stop DM
sudo systemctl set-default multi-user.target  # Boot to text mode
```

---

This troubleshooting guide provides systematic approaches to resolve X Window system issues. Keep it handy for quick reference during problem resolution.