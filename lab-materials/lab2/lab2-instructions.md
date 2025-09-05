# Lab 2: Display Manager Configuration

## Lab Information
- **Duration**: 45 minutes
- **Difficulty**: Intermediate
- **Chapter Reference**: 3.2.4, 3.2.4.1-3.2.4.5

## Learning Objectives
By the end of this lab, you will be able to:

✅ **Configure and switch between different display managers**
✅ **Customize display manager greetings and banners**
✅ **Manage display manager services and startup behavior**
✅ **Configure color depth and display settings**
✅ **Troubleshoot display manager issues**
✅ **Understand XDMCP and remote display concepts**
✅ **Configure display manager themes and appearance**

## Prerequisites
- Completion of Lab 1
- Access to the lab VM via `vagrant ssh`
- Basic understanding of X Window components
- Sudo privileges on the lab system

## Lab Environment Setup

1. **Access the lab environment**:
   ```bash
   vagrant ssh
   cd lab-materials/lab2
   ```

2. **Verify available display managers**:
   ```bash
   # Check installed display managers
   ls -la /usr/sbin/*dm
   
   # Check current default
   cat /etc/X11/default-display-manager
   
   # Check service status
   systemctl status display-manager
   ```

## Exercise 1: Display Manager Identification and Status (10 minutes)

### Objective
Identify and understand the different display managers available on your system.

### Instructions

1. **Inventory available display managers**:
   ```bash
   # List all display manager executables
   ls -la /usr/sbin/*dm
   
   # Check package information for each
   dpkg -l | grep -E "(gdm|lightdm|sddm|xdm)"
   
   # Check configuration directories
   ls -ld /etc/{gdm*,lightdm,sddm*,X11/xdm} 2>/dev/null
   ```

2. **Examine current display manager**:
   ```bash
   # Check which display manager is active
   systemctl status display-manager
   
   # Check the actual process
   ps aux | grep -E "(gdm|lightdm|sddm|xdm)" | grep -v grep
   
   # Check default display manager setting
   cat /etc/X11/default-display-manager
   update-alternatives --list x-session-manager 2>/dev/null || echo "No alternatives configured"
   ```

3. **Create display manager inventory**:
   ```bash
   cat > display-manager-inventory.txt << EOF
   === Display Manager Inventory ===
   Date: $(date)
   
   Current Default: $(basename $(cat /etc/X11/default-display-manager))
   Active Service: $(systemctl is-active display-manager)
   
   Installed Display Managers:
   $(dpkg -l | grep -E "(gdm|lightdm|sddm|xdm)" | awk '{print $2 " - " $3}')
   
   Configuration Directories:
   $(ls -ld /etc/{gdm*,lightdm,sddm*,X11/xdm} 2>/dev/null | awk '{print $9}')
   
   Current Process:
   $(ps aux | grep -E "(gdm|lightdm|sddm|xdm)" | grep -v grep | head -1)
   EOF
   
   cat display-manager-inventory.txt
   ```

### Questions
1. Which display managers are installed on your system?
2. Which display manager is currently active?
3. Where are the configuration files for each display manager located?

## Exercise 2: Switching Display Managers (15 minutes)

### Objective
Learn how to switch between different display managers and understand the configuration changes.

### Instructions

1. **Backup current configuration**:
   ```bash
   # Create backup directory
   mkdir -p ~/lab-backups/lab2
   
   # Backup current display manager setting
   sudo cp /etc/X11/default-display-manager ~/lab-backups/lab2/default-display-manager.backup
   
   # Backup any existing configurations
   sudo cp -r /etc/lightdm ~/lab-backups/lab2/lightdm.backup 2>/dev/null || echo "No lightdm config to backup"
   sudo cp -r /etc/gdm3 ~/lab-backups/lab2/gdm3.backup 2>/dev/null || echo "No gdm3 config to backup"
   ```

2. **Switch to LightDM (if not already active)**:
   ```bash
   # Check current display manager
   echo "Current: $(cat /etc/X11/default-display-manager)"
   
   # Configure LightDM as default
   echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager
   
   # Use dpkg-reconfigure for interactive switching
   sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure lightdm
   
   # Restart display manager service
   sudo systemctl restart display-manager
   
   # Verify the change
   systemctl status display-manager
   ps aux | grep lightdm | grep -v grep
   ```

3. **Switch to GDM3**:
   ```bash
   # Set GDM3 as default
   echo "/usr/sbin/gdm3" | sudo tee /etc/X11/default-display-manager
   
   # Restart service
   sudo systemctl restart display-manager
   
   # Verify the change
   systemctl status display-manager
   ps aux | grep gdm | grep -v grep
   ```

4. **Test switching with dpkg-reconfigure**:
   ```bash
   # Interactive switching (choose lightdm when prompted)
   sudo dpkg-reconfigure lightdm
   
   # Check what changed
   cat /etc/X11/default-display-manager
   
   # Restart to apply changes
   sudo systemctl restart display-manager
   ```

5. **Document the switching process**:
   ```bash
   cat > display-manager-switching.txt << EOF
   === Display Manager Switching Log ===
   Date: $(date)
   
   Original Display Manager: $(cat ~/lab-backups/lab2/default-display-manager.backup)
   
   Switch Method 1 - Direct file edit:
   - File: /etc/X11/default-display-manager
   - Command: echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager
   
   Switch Method 2 - dpkg-reconfigure:
   - Command: sudo dpkg-reconfigure lightdm
   - Interactive selection available
   
   Current Display Manager: $(cat /etc/X11/default-display-manager)
   Active Process: $(ps aux | grep -E "(gdm|lightdm)" | grep -v grep | head -1 | awk '{print $11}')
   EOF
   
   cat display-manager-switching.txt
   ```

### Questions
1. What file controls the default display manager?
2. What command can be used for interactive display manager switching?
3. Do you need to reboot after switching display managers?

## Exercise 3: Configuring Display Manager Greetings and Banners (10 minutes)

### Objective
Customize display manager appearance with custom greetings and banners.

### Instructions

1. **Configure LightDM greeting**:
   ```bash
   # Ensure LightDM is active
   sudo systemctl stop display-manager
   echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager
   
   # Check LightDM configuration
   sudo ls -la /etc/lightdm/
   
   # Create custom greeter configuration
   sudo mkdir -p /etc/lightdm/lightdm-gtk-greeter.conf.d
   
   cat | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf.d/01-lab-banner.conf << EOF
   [greeter]
   # Custom banner for lab
   banner-message-enable=true
   banner-message-text=Welcome to X Window Lab Environment
   background=/usr/share/pixmaps/ubuntu-logo.png
   EOF
   
   # Test the configuration
   sudo systemctl start display-manager
   ```

2. **Configure GDM3 banner (if available)**:
   ```bash
   # Switch to GDM3
   sudo systemctl stop display-manager
   echo "/usr/sbin/gdm3" | sudo tee /etc/X11/default-display-manager
   
   # Configure GDM3 banner using dconf
   sudo -u gdm dbus-launch gsettings set org.gnome.login-screen banner-message-enable true
   sudo -u gdm dbus-launch gsettings set org.gnome.login-screen banner-message-text "Linux Administration Lab System"
   
   # Alternative method using custom.conf
   cat | sudo tee /etc/gdm3/custom.conf << EOF
   [daemon]
   
   [security]
   
   [xdmcp]
   
   [chooser]
   
   [debug]
   
   [greeter]
   Banner=Linux X Window Laboratory
   EOF
   
   # Start GDM3
   sudo systemctl start display-manager
   ```

3. **Test and document banner configurations**:
   ```bash
   # Create documentation of banner settings
   cat > banner-configuration.txt << EOF
   === Display Manager Banner Configuration ===
   Date: $(date)
   
   LightDM Configuration:
   File: /etc/lightdm/lightdm-gtk-greeter.conf.d/01-lab-banner.conf
   Banner Text: "Welcome to X Window Lab Environment"
   
   GDM3 Configuration:
   File: /etc/gdm3/custom.conf
   Banner Text: "Linux X Window Laboratory"
   
   Configuration Commands Used:
   - LightDM: Configuration file method
   - GDM3: gsettings and custom.conf method
   
   Current Active: $(basename $(cat /etc/X11/default-display-manager))
   EOF
   
   cat banner-configuration.txt
   ```

### Questions
1. How do you configure banners for LightDM?
2. What are two methods to configure GDM3 banners?
3. Where are the configuration files stored for each display manager?

## Exercise 4: Color Depth and Display Settings (10 minutes)

### Objective
Configure display color depth and resolution settings through display manager and X configuration.

### Instructions

1. **Examine current display settings**:
   ```bash
   # Check current display information
   xrandr 2>/dev/null || echo "X not running in current session"
   
   # Check configuration files for display settings
   grep -r "DefaultDepth\|Depth\|Modes" /etc/X11/ 2>/dev/null
   
   # Check current color depth
   xdpyinfo 2>/dev/null | grep -E "depth|visual" || echo "X not accessible in current session"
   ```

2. **Configure color depth in xorg.conf**:
   ```bash
   # Backup current X configuration
   sudo cp /etc/X11/xorg.conf /etc/X11/xorg.conf.lab2.backup 2>/dev/null || echo "No existing xorg.conf"
   
   # Create configuration with specific color depth
   cat | sudo tee /etc/X11/xorg.conf << 'EOF'
   Section "Screen"
       Identifier    "Default Screen"
       Monitor       "Monitor0"
       Device        "Card0"
       DefaultDepth  24
       SubSection "Display"
           Depth     16
           Modes     "1024x768" "800x600"
       EndSubSection
       SubSection "Display"
           Depth     24
           Modes     "1024x768" "800x600" "640x480"
       EndSubSection
   EndSection
   
   Section "Monitor"
       Identifier   "Monitor0"
       ModelName    "Generic Monitor"
   EndSection
   
   Section "Device"
       Identifier  "Card0"
       Driver      "auto"
   EndSection
   EOF
   
   # Test the configuration
   sudo X -config /etc/X11/xorg.conf -retro :1 &
   sleep 3
   sudo pkill -f "X.*:1"
   ```

3. **Configure display manager specific settings**:
   ```bash
   # Configure LightDM display settings
   cat | sudo tee -a /etc/lightdm/lightdm.conf << 'EOF'
   
   [Seat:*]
   # Display resolution and color depth
   display-setup-script=/usr/local/bin/setup-display.sh
   EOF
   
   # Create display setup script
   cat | sudo tee /usr/local/bin/setup-display.sh << 'EOF'
   #!/bin/bash
   # Display setup for LightDM
   xrandr --output VGA-1 --mode 1024x768 2>/dev/null || true
   xrandr --output HDMI-1 --mode 1024x768 2>/dev/null || true
   EOF
   
   sudo chmod +x /usr/local/bin/setup-display.sh
   ```

4. **Document display configuration**:
   ```bash
   cat > display-configuration.txt << EOF
   === Display Configuration Summary ===
   Date: $(date)
   
   X Configuration File: /etc/X11/xorg.conf
   Default Color Depth: 24-bit
   Available Depths: 16-bit, 24-bit
   Available Modes: 1024x768, 800x600, 640x480
   
   Display Manager Settings:
   - LightDM: display-setup-script configured
   - Setup script: /usr/local/bin/setup-display.sh
   
   Configuration Test: X server started successfully with custom config
   EOF
   
   cat display-configuration.txt
   ```

### Questions
1. What color depths are commonly supported?
2. How do you specify available screen resolutions?
3. Where can display manager specific display settings be configured?

## Lab Completion Tasks

### Task 1: Display Manager Comparison
Create a comprehensive comparison of display managers:

```bash
cat > display-manager-comparison.txt << EOF
=== Display Manager Comparison ===
Date: $(date)

Feature Comparison:
                   LightDM    GDM3      SDDM      XDM
Configuration:     Simple     Complex   Qt-based  Basic
Banner Support:    Yes        Yes       Yes       Limited
Theme Support:     Yes        Yes       Yes       No
Remote Access:     Yes        Yes       Yes       Yes
Resource Usage:    Low        Medium    Medium    Very Low
Desktop Integration: Generic   GNOME     KDE       None

Configuration Files:
- LightDM: /etc/lightdm/
- GDM3: /etc/gdm3/
- SDDM: /etc/sddm/
- XDM: /etc/X11/xdm/

Switching Commands:
- Interactive: sudo dpkg-reconfigure [display-manager]
- Direct: echo "/usr/sbin/[dm]" | sudo tee /etc/X11/default-display-manager

Current Default: $(basename $(cat /etc/X11/default-display-manager))
EOF

cat display-manager-comparison.txt
```

### Task 2: Test All Display Managers
Test switching between all available display managers:

```bash
#!/bin/bash
# Test script for display manager switching

echo "=== Display Manager Switching Test ===" > dm-test-results.txt
echo "Date: $(date)" >> dm-test-results.txt
echo "" >> dm-test-results.txt

# List available display managers
DM_LIST=$(ls /usr/sbin/*dm 2>/dev/null | grep -E "(lightdm|gdm|sddm|xdm)")

for dm in $DM_LIST; do
    echo "Testing: $dm" >> dm-test-results.txt
    
    # Set as default
    echo "$dm" | sudo tee /etc/X11/default-display-manager > /dev/null
    
    # Test if service starts
    sudo systemctl restart display-manager
    sleep 3
    
    if systemctl is-active display-manager > /dev/null; then
        echo "  Status: SUCCESS" >> dm-test-results.txt
        echo "  Process: $(ps aux | grep $(basename $dm) | grep -v grep | head -1 | awk '{print $11}')" >> dm-test-results.txt
    else
        echo "  Status: FAILED" >> dm-test-results.txt
    fi
    echo "" >> dm-test-results.txt
done

# Restore original
sudo cp ~/lab-backups/lab2/default-display-manager.backup /etc/X11/default-display-manager
sudo systemctl restart display-manager

cat dm-test-results.txt
```

### Task 3: Create Configuration Templates
Create template configurations for different display managers:

```bash
# Create template directory
mkdir -p ~/lab-templates/display-managers

# LightDM template
cat > ~/lab-templates/display-managers/lightdm-custom.conf << 'EOF'
[Seat:*]
greeter-session=lightdm-gtk-greeter
autologin-user=
autologin-user-timeout=0
autologin-session=
user-session=default
allow-guest=false
guest-session=
session-cleanup-script=
greeter-wrapper=
display-setup-script=
session-setup-script=
session-wrapper=
greeter-hide-users=false
greeter-allow-guest=false
greeter-show-manual-login=false
greeter-show-remote-login=true
EOF

# GDM3 template  
cat > ~/lab-templates/display-managers/gdm3-custom.conf << 'EOF'
[daemon]
AutomaticLoginEnable=false
AutomaticLogin=

[security]
DisallowTCP=true
AllowRemoteAutoLogin=false

[xdmcp]
Enable=false
Port=177

[chooser]

[debug]
Enable=false

[greeter]
Banner=Custom Lab Environment
EOF

echo "Templates created in ~/lab-templates/display-managers/"
ls -la ~/lab-templates/display-managers/
```

## Verification and Cleanup

1. **Verify configurations work**:
   ```bash
   # Test current display manager
   systemctl status display-manager
   
   # Check banner is visible (requires GUI access)
   echo "Verify banner appears on login screen through VirtualBox GUI"
   
   # Test configuration files
   sudo nginx -t 2>/dev/null || echo "Configuration syntax check not applicable"
   ```

2. **Restore original configuration**:
   ```bash
   # Restore original display manager
   sudo cp ~/lab-backups/lab2/default-display-manager.backup /etc/X11/default-display-manager
   
   # Restore configuration backups
   sudo cp -r ~/lab-backups/lab2/lightdm.backup /etc/lightdm 2>/dev/null || echo "No lightdm backup to restore"
   sudo cp -r ~/lab-backups/lab2/gdm3.backup /etc/gdm3 2>/dev/null || echo "No gdm3 backup to restore"
   
   # Restart display manager
   sudo systemctl restart display-manager
   ```

3. **Archive lab results**:
   ```bash
   # Create results archive
   mkdir -p ~/lab-results/lab2
   cp *.txt ~/lab-results/lab2/
   cp -r ~/lab-templates ~/lab-results/lab2/
   
   # Mark lab complete
   echo "Lab 2 completed: $(date)" >> ~/lab-progress/completed.log
   ```

## Troubleshooting Common Issues

### Display Manager Won't Start
```bash
# Check service status and logs
systemctl status display-manager
journalctl -u display-manager -n 20

# Check X server logs
sudo tail -20 /var/log/Xorg.0.log

# Reset to working configuration
echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager
sudo systemctl restart display-manager
```

### Banner Not Displaying
```bash
# Check configuration syntax
sudo grep -n "banner" /etc/lightdm/lightdm-gtk-greeter.conf.d/*
sudo grep -n "Banner" /etc/gdm3/custom.conf

# Restart display manager
sudo systemctl restart display-manager

# Check logs for errors
journalctl -u display-manager | grep -i banner
```

### Permission Issues
```bash
# Fix configuration file permissions
sudo chmod 644 /etc/lightdm/lightdm-gtk-greeter.conf.d/*
sudo chmod 644 /etc/gdm3/custom.conf
sudo chown root:root /etc/lightdm/lightdm-gtk-greeter.conf.d/*
```

## Next Steps

After completing Lab 2, you should:

1. **Understand display manager differences** and when to use each
2. **Be able to switch display managers** confidently
3. **Know how to customize login appearance** 
4. **Proceed to Lab 3** which covers X Server troubleshooting

## Additional Resources

- LightDM Configuration: https://wiki.archlinux.org/title/LightDM
- GDM Configuration: https://help.gnome.org/admin/gdm/
- Display Manager Comparison: https://wiki.archlinux.org/title/Display_manager

---

**Lab 2 Complete!** ✅

You now understand how to configure and manage different display managers. In Lab 3, you'll learn to troubleshoot common X Window issues.