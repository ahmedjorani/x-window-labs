# Lab 4: Font Management and Advanced X Configuration

## Lab Information
- **Duration**: 75 minutes
- **Difficulty**: Intermediate
- **Chapter Reference**: 3.4.4, 3.4.5, 3.2.5, Advanced Configuration Topics

## Learning Objectives
By the end of this lab, you will be able to:

✅ **Manage X server font systems and FontConfig**
✅ **Install and configure custom fonts for system and users**
✅ **Troubleshoot font-related X server issues**
✅ **Configure widget toolkits and desktop environments**
✅ **Manage ~/.xsession-errors for application debugging**
✅ **Implement remote X Window access and security**
✅ **Configure advanced X server options and modules**
✅ **Optimize X Window performance and resource usage**

## Prerequisites
- Completion of Labs 1, 2, and 3
- Understanding of X Window troubleshooting
- Knowledge of X server configuration files
- Sudo privileges and advanced Linux skills

## Lab Environment Setup

1. **Access the lab environment**:
   ```bash
   vagrant ssh
   cd lab-materials/lab4
   ```

2. **Prepare font management environment**:
   ```bash
   # Create directories for font management
   mkdir -p ~/lab-fonts/{system,user,test}
   mkdir -p ~/lab-backups/lab4
   
   # Backup current font configuration
   sudo cp -r /etc/fonts ~/lab-backups/lab4/fonts.backup 2>/dev/null || echo "No fonts config to backup"
   cp -r ~/.fonts ~/lab-backups/lab4/user-fonts.backup 2>/dev/null || echo "No user fonts to backup"
   
   # Download test fonts (create some sample fonts for testing)
   cd ~/lab-fonts/test
   ```

## Exercise 1: FontConfig System Analysis (15 minutes)

### Objective
Understand the modern X Window font system and FontConfig architecture.

### Instructions

1. **Examine FontConfig system**:
   ```bash
   # Check FontConfig version and status
   fc-list --version
   
   # List all available fonts
   fc-list | wc -l
   echo "Total fonts available: $(fc-list | wc -l)"
   
   # List fonts by family
   fc-list : family | sort | uniq | head -20 > available-font-families.txt
   
   # Check font directories
   fc-list -d | head -10
   
   # Examine font configuration files
   ls -la /etc/fonts/
   ls -la /etc/fonts/conf.d/
   ```

2. **Analyze font cache and configuration**:
   ```bash
   # Check font cache status
   fc-cache -v > font-cache-info.txt 2>&1
   
   # Show font configuration information
   fc-conflist > font-config-list.txt
   
   # Test font matching
   fc-match "serif" > font-matching-test.txt
   fc-match "sans-serif" >> font-matching-test.txt
   fc-match "monospace" >> font-matching-test.txt
   fc-match "DejaVu Sans" >> font-matching-test.txt
   
   cat font-matching-test.txt
   ```

3. **Create font system inventory**:
   ```bash
   cat > font-system-inventory.txt << EOF
   === Font System Inventory ===
   Date: $(date)
   
   FontConfig Version: $(fc-list --version 2>&1 | head -1)
   Total Fonts Available: $(fc-list | wc -l)
   
   Font Directories:
   System: /usr/share/fonts/
   Local: /usr/local/share/fonts/
   User: ~/.fonts/
   
   Configuration Directories:
   Global: /etc/fonts/
   System: /etc/fonts/conf.d/
   User: ~/.config/fontconfig/
   
   Font Cache Locations:
   $(fc-cache -v 2>&1 | grep "cache" | head -5)
   
   Default Font Families:
   Serif: $(fc-match "serif" | cut -d: -f1)
   Sans-serif: $(fc-match "sans-serif" | cut -d: -f1)
   Monospace: $(fc-match "monospace" | cut -d: -f1)
   EOF
   
   cat font-system-inventory.txt
   ```

### Questions
1. How many fonts are currently available on the system?
2. Where are font configuration files stored?
3. What command rebuilds the font cache?

## Exercise 2: Installing and Managing Fonts (20 minutes)

### Objective
Learn to install fonts system-wide and per-user, and manage font configurations.

### Instructions

1. **Install system-wide fonts**:
   ```bash
   # Create test fonts directory
   sudo mkdir -p /usr/local/share/fonts/lab-fonts
   
   # Download and install Liberation fonts (if not present)
   cd ~/lab-fonts/system
   
   # Check current Liberation fonts
   fc-list | grep -i liberation > liberation-fonts-before.txt
   
   # Install additional font package for testing
   sudo apt-get update
   sudo apt-get install -y fonts-noto-core fonts-firacode
   
   # Update font cache
   sudo fc-cache -f -v
   
   # Verify installation
   fc-list | grep -i noto > noto-fonts-after.txt
   fc-list | grep -i fira > fira-fonts-after.txt
   
   echo "Noto fonts installed:"
   cat noto-fonts-after.txt | wc -l
   echo "Fira fonts installed:"
   cat fira-fonts-after.txt | wc -l
   ```

2. **Create custom user font installation**:
   ```bash
   # Create user font directory
   mkdir -p ~/.fonts
   
   # Create a test scenario with font copying
   # (In real environment, you would copy actual font files)
   
   # Check user fonts before
   fc-list : file | grep -E "(/home/|$HOME)" > user-fonts-before.txt || touch user-fonts-before.txt
   
   # Simulate user font installation by creating symbolic links to system fonts
   cd ~/.fonts
   ln -s /usr/share/fonts/truetype/liberation/* . 2>/dev/null || echo "Liberation fonts not found"
   
   # Update user font cache
   fc-cache -f ~/.fonts
   
   # Check user fonts after
   fc-list : file | grep -E "(/home/|$HOME)" > ~/lab-fonts/user/user-fonts-after.txt
   
   echo "User fonts before: $(cat ~/lab-fonts/system/user-fonts-before.txt | wc -l)"
   echo "User fonts after: $(cat ~/lab-fonts/user/user-fonts-after.txt | wc -l)"
   ```

3. **Test font availability in X applications**:
   ```bash
   # Create font testing script
   cat > test-fonts.sh << 'EOF'
   #!/bin/bash
   # Font testing script for X applications
   
   echo "=== Font Availability Test ==="
   echo "Date: $(date)"
   
   # Test if X is available
   if [ -z "$DISPLAY" ]; then
       export DISPLAY=:0
   fi
   
   # Test common font families
   echo "Testing font families:"
   for family in "serif" "sans-serif" "monospace" "DejaVu Sans" "Liberation Sans"; do
       result=$(fc-match "$family" 2>/dev/null)
       if [ $? -eq 0 ]; then
           echo "  $family: $result"
       else
           echo "  $family: NOT FOUND"
       fi
   done
   
   # Test newly installed fonts
   echo ""
   echo "Testing new fonts:"
   fc-list | grep -i "noto\|fira" | head -5
   
   # Test font rendering (if X is available)
   if xset q >/dev/null 2>&1; then
       echo ""
       echo "X server font path:"
       xset q | grep -A 10 "Font Path"
   else
       echo ""
       echo "X server not accessible for font path check"
   fi
   EOF
   
   chmod +x test-fonts.sh
   ./test-fonts.sh > font-test-results.txt
   cat font-test-results.txt
   ```

4. **Configure font preferences**:
   ```bash
   # Create user font configuration
   mkdir -p ~/.config/fontconfig
   
   cat > ~/.config/fontconfig/fonts.conf << 'EOF'
   <?xml version="1.0"?>
   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
   <fontconfig>
     <!-- Set default fonts -->
     <alias>
       <family>serif</family>
       <prefer>
         <family>Liberation Serif</family>
         <family>DejaVu Serif</family>
       </prefer>
     </alias>
     
     <alias>
       <family>sans-serif</family>
       <prefer>
         <family>Liberation Sans</family>
         <family>DejaVu Sans</family>
       </prefer>
     </alias>
     
     <alias>
       <family>monospace</family>
       <prefer>
         <family>Liberation Mono</family>
         <family>DejaVu Sans Mono</family>
       </prefer>
     </alias>
     
     <!-- Font rendering settings -->
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
   
   # Update font cache with new configuration
   fc-cache -f
   
   # Test new configuration
   echo "=== Font Configuration Test ===" > font-config-test.txt
   fc-match "serif" >> font-config-test.txt
   fc-match "sans-serif" >> font-config-test.txt
   fc-match "monospace" >> font-config-test.txt
   
   cat font-config-test.txt
   ```

### Questions
1. What's the difference between system-wide and user font installation?
2. How do you configure font preferences for a user?
3. What command updates the font cache after installing new fonts?

## Exercise 3: X Session Error Debugging (15 minutes)

### Objective
Learn to use ~/.xsession-errors for debugging X applications and desktop issues.

### Instructions

1. **Examine existing session errors**:
   ```bash
   # Check if .xsession-errors exists
   ls -la ~/.xsession-errors 2>/dev/null || echo "No .xsession-errors file found"
   
   # If it exists, analyze it
   if [ -f ~/.xsession-errors ]; then
       echo "=== Existing Session Errors ===" > session-error-analysis.txt
       echo "File size: $(stat -c%s ~/.xsession-errors) bytes" >> session-error-analysis.txt
       echo "Last modified: $(stat -c%y ~/.xsession-errors)" >> session-error-analysis.txt
       echo "" >> session-error-analysis.txt
       echo "Recent errors:" >> session-error-analysis.txt
       tail -20 ~/.xsession-errors >> session-error-analysis.txt
   else
       echo "No existing .xsession-errors file" > session-error-analysis.txt
   fi
   ```

2. **Generate test session errors**:
   ```bash
   # Start X session if not running (skip if already in GUI)
   if [ -z "$DISPLAY" ]; then
       export DISPLAY=:0
   fi
   
   # Create script to generate test errors
   cat > generate-test-errors.sh << 'EOF'
   #!/bin/bash
   # Generate test errors for .xsession-errors
   
   echo "Generating test X session errors..."
   
   # Try to run non-existent X application
   nonexistent-x-app 2>&1 &
   
   # Try to access invalid display
   DISPLAY=:999 xterm 2>&1 &
   
   # Generate font warning
   echo "Testing font warnings..." >&2
   
   # Try to run application with invalid options
   xterm -invalidoption 2>&1 &
   
   # Wait a moment for errors to be generated
   sleep 2
   
   echo "Test errors generated"
   EOF
   
   chmod +x generate-test-errors.sh
   
   # Backup current .xsession-errors if it exists
   cp ~/.xsession-errors ~/.xsession-errors.backup 2>/dev/null
   
   # Clear current errors for clean test
   > ~/.xsession-errors
   
   # Generate test errors
   ./generate-test-errors.sh
   
   # Wait for errors to be written
   sleep 3
   
   # Analyze new errors
   echo "=== Generated Test Errors ===" >> session-error-analysis.txt
   if [ -f ~/.xsession-errors ] && [ -s ~/.xsession-errors ]; then
       cat ~/.xsession-errors >> session-error-analysis.txt
   else
       echo "No errors generated or captured" >> session-error-analysis.txt
   fi
   ```

3. **Create session error monitoring tools**:
   ```bash
   # Create real-time error monitor
   cat > monitor-session-errors.sh << 'EOF'
   #!/bin/bash
   # Real-time .xsession-errors monitor
   
   ERROR_FILE="$HOME/.xsession-errors"
   
   echo "=== X Session Error Monitor ==="
   echo "Monitoring: $ERROR_FILE"
   echo "Press Ctrl+C to stop"
   echo ""
   
   if [ ! -f "$ERROR_FILE" ]; then
       echo "Creating $ERROR_FILE..."
       touch "$ERROR_FILE"
   fi
   
   # Monitor file for changes
   tail -f "$ERROR_FILE" | while read line; do
       echo "[$(date '+%H:%M:%S')] $line"
   done
   EOF
   
   chmod +x monitor-session-errors.sh
   
   # Create error analysis script
   cat > analyze-session-errors.sh << 'EOF'
   #!/bin/bash
   # Analyze .xsession-errors content
   
   ERROR_FILE="$HOME/.xsession-errors"
   
   if [ ! -f "$ERROR_FILE" ]; then
       echo "No .xsession-errors file found"
       exit 1
   fi
   
   echo "=== X Session Error Analysis ==="
   echo "File: $ERROR_FILE"
   echo "Size: $(stat -c%s $ERROR_FILE) bytes"
   echo "Lines: $(wc -l < $ERROR_FILE)"
   echo ""
   
   echo "=== Error Categories ==="
   echo "Font errors: $(grep -ci font $ERROR_FILE)"
   echo "Display errors: $(grep -ci display $ERROR_FILE)"
   echo "Permission errors: $(grep -ci permission $ERROR_FILE)"
   echo "Application errors: $(grep -ci "command not found\|not found\|no such" $ERROR_FILE)"
   echo ""
   
   echo "=== Recent Errors (last 10) ==="
   tail -10 "$ERROR_FILE"
   EOF
   
   chmod +x analyze-session-errors.sh
   ./analyze-session-errors.sh >> session-error-analysis.txt
   
   cat session-error-analysis.txt
   ```

### Questions
1. What types of errors are commonly found in ~/.xsession-errors?
2. How can you monitor X session errors in real-time?
3. Why might some GUI applications not show errors in the terminal?

## Exercise 4: Remote X Window Configuration (15 minutes)

### Objective
Configure and test remote X Window access using SSH X11 forwarding and XDMCP.

### Instructions

1. **Configure SSH X11 forwarding**:
   ```bash
   # Check current SSH configuration
   grep -E "X11Forwarding|X11DisplayOffset" /etc/ssh/sshd_config
   
   # Backup SSH configuration
   sudo cp /etc/ssh/sshd_config ~/lab-backups/lab4/sshd_config.backup
   
   # Enable X11 forwarding if not already enabled
   sudo sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
   sudo sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config
   sudo sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config
   
   # Restart SSH service
   sudo systemctl restart ssh
   
   # Document SSH X11 configuration
   echo "=== SSH X11 Configuration ===" > remote-x-config.txt
   echo "Date: $(date)" >> remote-x-config.txt
   echo "" >> remote-x-config.txt
   grep -E "X11Forwarding|X11DisplayOffset|X11UseLocalhost" /etc/ssh/sshd_config >> remote-x-config.txt
   ```

2. **Test X11 forwarding**:
   ```bash
   # Test local X11 forwarding
   echo "" >> remote-x-config.txt
   echo "=== X11 Forwarding Test ===" >> remote-x-config.txt
   
   # Test if xauth is available
   which xauth >> remote-x-config.txt
   
   # Check current display
   echo "Current DISPLAY: $DISPLAY" >> remote-x-config.txt
   
   # Test X11 access
   if xset q >/dev/null 2>&1; then
       echo "X11 access: SUCCESS" >> remote-x-config.txt
   else
       echo "X11 access: FAILED" >> remote-x-config.txt
   fi
   
   # Create test script for remote X11
   cat > test-remote-x11.sh << 'EOF'
   #!/bin/bash
   # Test remote X11 applications
   
   echo "Testing remote X11 applications..."
   
   # Test basic X applications
   applications=("xterm" "xclock" "xeyes" "xlogo")
   
   for app in "${applications[@]}"; do
       if which "$app" >/dev/null 2>&1; then
           echo "  $app: Available"
           # Quick test (start and immediately close)
           timeout 2 "$app" >/dev/null 2>&1 &
       else
           echo "  $app: Not installed"
       fi
   done
   
   wait
   echo "Remote X11 test completed"
   EOF
   
   chmod +x test-remote-x11.sh
   ./test-remote-x11.sh >> remote-x-config.txt
   ```

3. **Configure XDMCP (demonstration)**:
   ```bash
   # Note: XDMCP configuration (for reference only in this lab)
   echo "" >> remote-x-config.txt
   echo "=== XDMCP Configuration Reference ===" >> remote-x-config.txt
   
   # Check if XDMCP is supported
   if [ -f /etc/gdm3/custom.conf ]; then
       echo "GDM3 XDMCP configuration:" >> remote-x-config.txt
       echo "[xdmcp]" >> remote-x-config.txt
       echo "Enable=true" >> remote-x-config.txt
       echo "Port=177" >> remote-x-config.txt
   fi
   
   if [ -f /etc/lightdm/lightdm.conf ]; then
       echo "LightDM XDMCP configuration:" >> remote-x-config.txt
       echo "[XDMCPServer]" >> remote-x-config.txt
       echo "enabled=true" >> remote-x-config.txt
       echo "port=177" >> remote-x-config.txt
   fi
   
   # Security considerations
   cat >> remote-x-config.txt << 'EOF'
   
   === Security Considerations ===
   
   SSH X11 Forwarding:
   - Secure encrypted tunnel
   - Automatic display number assignment
   - User authentication required
   
   XDMCP:
   - Unencrypted protocol
   - Network authentication required
   - Should be used only on trusted networks
   - Firewall configuration needed
   
   Best Practices:
   - Use SSH X11 forwarding for remote access
   - Disable XDMCP on production systems
   - Use VPN for remote X access over internet
   - Monitor X11 forwarding logs
   EOF
   
   cat remote-x-config.txt
   ```

### Questions
1. What SSH configuration options enable X11 forwarding?
2. What are the security differences between SSH X11 forwarding and XDMCP?
3. How do you test if X11 forwarding is working properly?

## Exercise 5: Advanced X Configuration and Performance (10 minutes)

### Objective
Implement advanced X server configuration options and performance optimizations.

### Instructions

1. **Configure advanced X server modules**:
   ```bash
   # Create advanced X configuration
   cat > advanced-xorg.conf << 'EOF'
   Section "Files"
       ModulePath   "/usr/lib/xorg/modules"
       FontPath     "catalogue:/etc/X11/fontpath.d"
       FontPath     "built-ins"
   EndSection
   
   Section "Module"
       Load "dbe"         # Double Buffer Extension
       Load "glx"         # OpenGL Extension
       Load "dri2"        # Direct Rendering Infrastructure
       Load "composite"   # Composite Extension
   EndSection
   
   Section "Extensions"
       Option "Composite" "Enable"
       Option "RENDER" "Enable"
       Option "DAMAGE" "Enable"
   EndSection
   
   Section "Device"
       Identifier  "AdvancedVideoCard"
       Driver      "auto"
       Option      "AccelMethod" "glamor"
       Option      "DRI" "3"
   EndSection
   
   Section "Screen"
       Identifier    "AdvancedScreen"
       Device        "AdvancedVideoCard"
       DefaultDepth  24
       
       SubSection "Display"
           Depth     24
           Modes     "1920x1080" "1680x1050" "1440x900" "1024x768"
       EndSubSection
   EndSection
   
   Section "ServerFlags"
       Option "BlankTime" "10"
       Option "StandbyTime" "20"
       Option "SuspendTime" "30"
       Option "OffTime" "40"
       Option "DontZap" "false"
   EndSection
   EOF
   
   # Test advanced configuration
   sudo X -config advanced-xorg.conf -retro :12 &
   ADVANCED_PID=$!
   sleep 5
   
   if ps -p $ADVANCED_PID > /dev/null; then
       echo "Advanced configuration test: SUCCESS" > advanced-config-results.txt
       sudo kill $ADVANCED_PID
   else
       echo "Advanced configuration test: FAILED" > advanced-config-results.txt
   fi
   ```

2. **Performance monitoring and optimization**:
   ```bash
   # Create performance monitoring script
   cat > x-performance-monitor.sh << 'EOF'
   #!/bin/bash
   # X server performance monitoring
   
   echo "=== X Server Performance Monitor ==="
   echo "Date: $(date)"
   echo ""
   
   # Check X server process
   echo "=== X Server Process Information ==="
   ps aux | grep X | grep -v grep | head -1
   echo ""
   
   # Memory usage
   echo "=== Memory Usage ==="
   X_PID=$(pgrep -f "X.*:0" | head -1)
   if [ -n "$X_PID" ]; then
       echo "X Server PID: $X_PID"
       ps -o pid,vsz,rss,pcpu,pmem,comm -p $X_PID
   else
       echo "X Server not running"
   fi
   echo ""
   
   # Display information
   echo "=== Display Information ==="
   if [ -n "$DISPLAY" ]; then
       xrandr 2>/dev/null | head -10 || echo "xrandr not accessible"
       echo ""
       xdpyinfo 2>/dev/null | grep -E "dimensions|resolution|depth" || echo "xdpyinfo not accessible"
   else
       echo "No DISPLAY environment variable set"
   fi
   echo ""
   
   # OpenGL information
   echo "=== OpenGL Information ==="
   glxinfo 2>/dev/null | grep -E "OpenGL|GLX" | head -5 || echo "glxinfo not available"
   EOF
   
   chmod +x x-performance-monitor.sh
   ./x-performance-monitor.sh > performance-results.txt
   cat performance-results.txt
   ```

3. **Create optimization recommendations**:
   ```bash
   cat > x-optimization-guide.txt << 'EOF'
   === X Server Optimization Guide ===
   
   Performance Optimizations:
   
   1. Video Driver Optimization:
      - Use native drivers when available
      - Enable hardware acceleration (DRI/DRI2/DRI3)
      - Configure AccelMethod appropriately
   
   2. Memory Management:
      - Monitor X server memory usage
      - Restart X server periodically on long-running systems
      - Use appropriate color depth (24-bit vs 32-bit)
   
   3. Font Optimization:
      - Use FontConfig for modern font handling
      - Avoid legacy font servers (xfs)
      - Enable font antialiasing and hinting
   
   4. Display Optimization:
      - Use appropriate resolution and refresh rate
      - Enable monitor power management
      - Configure optimal color depth
   
   5. Network Optimization (for remote X):
      - Use SSH compression (-C option)
      - Limit X11 forwarding to trusted users
      - Consider VNC for slow connections
   
   Configuration Examples:
   
   High Performance:
   Option "AccelMethod" "glamor"
   Option "DRI" "3"
   Load "glx"
   
   Low Resource Usage:
   DefaultDepth 16
   Option "AccelMethod" "none"
   Option "SWcursor" "true"
   
   Monitoring Commands:
   - ps aux | grep X
   - xrandr
   - glxinfo
   - xdpyinfo
   EOF
   
   cat x-optimization-guide.txt
   ```

### Questions
1. What X server modules provide hardware acceleration?
2. How do you monitor X server performance and resource usage?
3. What configuration options can reduce X server memory usage?

## Lab Completion Tasks

### Task 1: Comprehensive Font Management Documentation
Create complete font management procedures:

```bash
cat > complete-font-management.txt << 'EOF'
=== Complete Font Management Guide ===

INSTALLATION PROCEDURES:

System-wide Installation:
1. Copy fonts to: /usr/share/fonts/[category]/
2. Set permissions: chmod 644 *.ttf *.otf
3. Update cache: sudo fc-cache -f -v
4. Verify: fc-list | grep "font-name"

User Installation:
1. Create directory: mkdir -p ~/.fonts
2. Copy fonts to: ~/.fonts/
3. Update cache: fc-cache -f ~/.fonts
4. Verify: fc-list : file | grep $HOME

CONFIGURATION:

Global Configuration: /etc/fonts/fonts.conf
User Configuration: ~/.config/fontconfig/fonts.conf

Font Matching Priority:
1. User configuration
2. System configuration
3. Default configuration

TROUBLESHOOTING:

Font Not Found:
- Check font installation path
- Rebuild font cache
- Verify font file permissions
- Check fontconfig configuration

Poor Font Rendering:
- Enable antialiasing
- Configure hinting
- Check subpixel rendering
- Verify font smoothing settings

COMMANDS REFERENCE:

fc-list                 # List all fonts
fc-cache -f -v         # Rebuild font cache
fc-match "family"      # Test font matching
fc-conflist           # Show configuration files
fc-query font.ttf     # Query font information

LEGACY FONT SYSTEM:

X11 Font Server (deprecated):
- Service: xfs
- Configuration: /etc/X11/fs/config
- Font path: unix/:7100

Modern replacement:
- FontConfig system
- Built-in fonts
- Automatic font discovery
EOF

cat complete-font-management.txt
```

### Task 2: Create X Window Administration Toolkit
Build a comprehensive toolkit for X Window administration:

```bash
# Create toolkit directory
mkdir -p ~/x-window-toolkit

# Create main administration script
cat > ~/x-window-toolkit/x-admin.sh << 'EOF'
#!/bin/bash
# X Window Administration Toolkit

TOOLKIT_VERSION="1.0"
CONFIG_BACKUP_DIR="$HOME/x-backups"

show_menu() {
    echo "=== X Window Administration Toolkit v$TOOLKIT_VERSION ==="
    echo "1. System Information"
    echo "2. Configuration Management"
    echo "3. Font Management"
    echo "4. Troubleshooting"
    echo "5. Performance Monitoring"
    echo "6. Remote Access Setup"
    echo "7. Backup/Restore"
    echo "8. Emergency Recovery"
    echo "9. Exit"
    echo ""
    read -p "Select option (1-9): " choice
}

system_info() {
    echo "=== X Window System Information ==="
    echo "X Server Version: $(X -version 2>&1 | head -1)"
    echo "Display Manager: $(basename $(cat /etc/X11/default-display-manager 2>/dev/null))"
    echo "Default Target: $(systemctl get-default)"
    echo "X Server Status: $(systemctl is-active display-manager)"
    echo "Total Fonts: $(fc-list | wc -l)"
    echo "Video Driver: $(lspci | grep -i vga)"
    echo ""
    read -p "Press Enter to continue..."
}

config_management() {
    echo "=== Configuration Management ==="
    echo "1. View current configuration"
    echo "2. Generate new configuration"
    echo "3. Edit configuration"
    echo "4. Test configuration"
    echo ""
    read -p "Select option: " config_choice
    
    case $config_choice in
        1) cat /etc/X11/xorg.conf 2>/dev/null || echo "No xorg.conf found" ;;
        2) sudo X -configure && echo "Configuration generated as xorg.conf.new" ;;
        3) sudo nano /etc/X11/xorg.conf ;;
        4) sudo X -config /etc/X11/xorg.conf -retro :99 & sleep 3; sudo pkill -f "X.*:99" ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Add more functions as needed...

# Main loop
while true; do
    show_menu
    case $choice in
        1) system_info ;;
        2) config_management ;;
        9) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
EOF

chmod +x ~/x-window-toolkit/x-admin.sh

# Create emergency recovery script
cp emergency-x-recovery.sh ~/x-window-toolkit/

# Create documentation
cat > ~/x-window-toolkit/README.md << 'EOF'
# X Window Administration Toolkit

This toolkit provides comprehensive X Window system administration capabilities.

## Scripts Included:

- x-admin.sh: Main administration interface
- emergency-x-recovery.sh: Emergency recovery procedures
- x-performance-monitor.sh: Performance monitoring
- analyze-xorg-log.sh: Log analysis

## Usage:

```bash
cd ~/x-window-toolkit
./x-admin.sh
```

## Emergency Recovery:

```bash
./emergency-x-recovery.sh
```
EOF

echo "X Window Administration Toolkit created in ~/x-window-toolkit/"
ls -la ~/x-window-toolkit/
```

### Task 3: Final Comprehensive Test
Run complete system validation:

```bash
cat > final-validation.sh << 'EOF'
#!/bin/bash
# Final Lab 4 Validation Script

echo "=== Lab 4 Final Validation ==="
echo "Date: $(date)"
echo ""

# Test 1: Font system
echo "Test 1: Font System Validation"
font_count=$(fc-list | wc -l)
if [ $font_count -gt 50 ]; then
    echo "  ✓ Font system: PASS ($font_count fonts available)"
else
    echo "  ✗ Font system: FAIL (insufficient fonts)"
fi

# Test 2: User font configuration
echo "Test 2: User Font Configuration"
if [ -f ~/.config/fontconfig/fonts.conf ]; then
    echo "  ✓ User font config: PASS"
else
    echo "  ✗ User font config: FAIL"
fi

# Test 3: SSH X11 forwarding
echo "Test 3: SSH X11 Configuration"
if grep -q "X11Forwarding yes" /etc/ssh/sshd_config; then
    echo "  ✓ SSH X11 forwarding: PASS"
else
    echo "  ✗ SSH X11 forwarding: FAIL"
fi

# Test 4: Session error monitoring
echo "Test 4: Session Error Tools"
if [ -f analyze-session-errors.sh ] && [ -f monitor-session-errors.sh ]; then
    echo "  ✓ Error monitoring tools: PASS"
else
    echo "  ✗ Error monitoring tools: FAIL"
fi

# Test 5: Advanced configuration
echo "Test 5: Advanced Configuration"
if [ -f advanced-xorg.conf ]; then
    echo "  ✓ Advanced config: PASS"
else
    echo "  ✗ Advanced config: FAIL"
fi

# Test 6: Administration toolkit
echo "Test 6: Administration Toolkit"
if [ -f ~/x-window-toolkit/x-admin.sh ]; then
    echo "  ✓ Admin toolkit: PASS"
else
    echo "  ✗ Admin toolkit: FAIL"
fi

echo ""
echo "=== Lab 4 Validation Complete ==="
EOF

chmod +x final-validation.sh
./final-validation.sh > lab4-validation-results.txt
cat lab4-validation-results.txt
```

## Verification and Cleanup

1. **Verify all lab objectives completed**:
   ```bash
   # Check font management capabilities
   fc-list | wc -l
   fc-cache -v > /dev/null && echo "Font cache working"
   
   # Check session error tools
   ls -la *session-errors* *monitor*
   
   # Verify remote X configuration
   grep X11Forwarding /etc/ssh/sshd_config
   
   # Check toolkit creation
   ls -la ~/x-window-toolkit/
   ```

2. **Create final lab archive**:
   ```bash
   # Archive all lab results
   mkdir -p ~/lab-results/lab4
   cp *.txt *.sh *.conf ~/lab-results/lab4/
   cp -r ~/x-window-toolkit ~/lab-results/lab4/
   
   # Create summary
   echo "=== Lab 4 Summary ===" > ~/lab-results/lab4/SUMMARY.md
   echo "Font Management: ✓" >> ~/lab-results/lab4/SUMMARY.md
   echo "Session Error Debugging: ✓" >> ~/lab-results/lab4/SUMMARY.md
   echo "Remote X Configuration: ✓" >> ~/lab-results/lab4/SUMMARY.md
   echo "Advanced Configuration: ✓" >> ~/lab-results/lab4/SUMMARY.md
   echo "Administration Toolkit: ✓" >> ~/lab-results/lab4/SUMMARY.md
   ```

3. **Restore system to clean state**:
   ```bash
   # Restore original configurations
   sudo cp ~/lab-backups/lab4/sshd_config.backup /etc/ssh/sshd_config 2>/dev/null
   
   # Clean up test files
   rm -f ~/.xsession-errors.backup
   
   # Mark lab complete
   echo "Lab 4 completed: $(date)" >> ~/lab-progress/completed.log
   echo "All X Window labs completed successfully!" >> ~/lab-progress/completed.log
   ```

## Troubleshooting Lab 4

### Font Issues
```bash
# Reset font cache
fc-cache -f -v

# Remove user font config
mv ~/.config/fontconfig ~/.config/fontconfig.backup

# Test with system defaults
fc-match serif
```

### SSH X11 Issues
```bash
# Restart SSH service
sudo systemctl restart ssh

# Test local X11 access
xset q

# Check SSH configuration
sshd -T | grep -i x11
```

### Performance Issues
```bash
# Check X server resource usage
ps aux | grep X

# Restart display manager
sudo systemctl restart display-manager
```

## Course Completion

🎉 **Congratulations!** You have successfully completed all X Window System labs!

### Skills Acquired:
- ✅ X Window component identification and management
- ✅ Display manager configuration and switching  
- ✅ Advanced X server troubleshooting
- ✅ Font system management and configuration
- ✅ Remote X Window access setup
- ✅ Performance optimization and monitoring
- ✅ Emergency recovery procedures
- ✅ Comprehensive system administration

### Next Steps:
1. **Practice** these skills in real environments
2. **Explore** desktop environment customization
3. **Study** Wayland as the future of Linux graphics
4. **Apply** knowledge to production systems

## Additional Resources

- FontConfig Documentation: https://www.freedesktop.org/wiki/Software/fontconfig/
- X.Org Performance Guide: https://www.x.org/wiki/Development/Documentation/Performance/
- SSH X11 Forwarding: `man ssh_config`
- Advanced X Configuration: `man xorg.conf`

---

**Lab 4 Complete!** ✅ **All X Window Labs Complete!** 🎓

You now have comprehensive X Window system administration skills covering all aspects from basic components to advanced troubleshooting and optimization.