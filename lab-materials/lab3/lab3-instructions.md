# Lab 3: X Server Troubleshooting

## Lab Information
- **Duration**: 90 minutes
- **Difficulty**: Advanced
- **Chapter Reference**: 3.4, 3.4.1-3.4.5

## Learning Objectives
By the end of this lab, you will be able to:

✅ **Analyze X server log files to identify issues**
✅ **Generate and test X server configurations**
✅ **Troubleshoot video driver compatibility problems**
✅ **Resolve display monitor synchronization issues**
✅ **Fix font-related X server errors**
✅ **Use alternative console access during X failures**
✅ **Apply systematic troubleshooting methodology**
✅ **Create backup and recovery procedures**

## Prerequisites
- Completion of Labs 1 and 2
- Understanding of X Window components
- Knowledge of display manager configuration
- Sudo privileges and basic Linux troubleshooting skills

## Lab Environment Setup

1. **Access the lab environment**:
   ```bash
   vagrant ssh
   cd lab-materials/lab3
   ```

2. **Prepare troubleshooting environment**:
   ```bash
   # Create backup directory
   mkdir -p ~/lab-backups/lab3
   
   # Backup current working configuration
   sudo cp /etc/X11/xorg.conf ~/lab-backups/lab3/xorg.conf.working 2>/dev/null || echo "No existing xorg.conf"
   sudo cp /etc/X11/default-display-manager ~/lab-backups/lab3/default-display-manager.working
   
   # Create broken configurations for testing
   cp /home/vagrant/lab-configs/broken-xorg.conf ~/lab-configs/ 2>/dev/null || echo "No pre-made broken config found"
   ```

## Exercise 1: Log File Analysis and Interpretation (20 minutes)

### Objective
Learn to read and interpret X server log files to identify common problems.

### Instructions

1. **Examine X server log structure**:
   ```bash
   # Check X server logs
   ls -la /var/log/Xorg*
   
   # View current log file structure
   head -20 /var/log/Xorg.0.log
   
   # Understand log entry markers
   grep -E "^\(II\)|^\(WW\)|^\(EE\)|^\(\*\*\)|^\(\+\+\)|^\(--\)" /var/log/Xorg.0.log | head -10
   ```

2. **Create a log analysis script**:
   ```bash
   cat > analyze-xorg-log.sh << 'EOF'
   #!/bin/bash
   # X server log analysis script
   
   LOG_FILE="/var/log/Xorg.0.log"
   
   if [ ! -f "$LOG_FILE" ]; then
       echo "Error: X server log file not found at $LOG_FILE"
       exit 1
   fi
   
   echo "=== X Server Log Analysis ==="
   echo "Date: $(date)"
   echo "Log file: $LOG_FILE"
   echo "Log size: $(stat -c%s $LOG_FILE) bytes"
   echo ""
   
   echo "=== Error Summary ==="
   echo "Errors (EE): $(grep -c "^(EE)" $LOG_FILE)"
   echo "Warnings (WW): $(grep -c "^(WW)" $LOG_FILE)"
   echo "Info (II): $(grep -c "^(II)" $LOG_FILE)"
   echo ""
   
   echo "=== Critical Errors ==="
   grep "^(EE)" $LOG_FILE | head -5
   echo ""
   
   echo "=== Warnings ==="
   grep "^(WW)" $LOG_FILE | head -5
   echo ""
   
   echo "=== Driver Information ==="
   grep -i "driver" $LOG_FILE | grep -E "(Loading|loaded|UnloadModule)" | head -5
   echo ""
   
   echo "=== Display Information ==="
   grep -i "display\|screen\|monitor" $LOG_FILE | grep -v "^(--)" | head -5
   EOF
   
   chmod +x analyze-xorg-log.sh
   ./analyze-xorg-log.sh > log-analysis-baseline.txt
   cat log-analysis-baseline.txt
   ```

3. **Generate problematic scenarios and analyze logs**:
   ```bash
   # Stop X server to generate clean logs
   sudo systemctl stop display-manager
   
   # Create intentionally broken configuration
   cat | sudo tee /etc/X11/xorg.conf << 'EOF'
   Section "Device"
       Identifier  "BrokenCard"
       Driver      "nonexistent-driver"
   EndSection
   
   Section "Monitor"
       Identifier   "BrokenMonitor"
       HorizSync    999999.0-999999.0
       VertRefresh  999999.0-999999.0
   EndSection
   
   Section "Screen"
       Identifier    "BrokenScreen"
       Device        "BrokenCard"
       Monitor       "BrokenMonitor"
       DefaultDepth  999
   EndSection
   EOF
   
   # Try to start X server and capture errors
   sudo X :1 &
   sleep 5
   sudo pkill -f "X.*:1"
   
   # Analyze the new log
   ./analyze-xorg-log.sh > log-analysis-broken.txt
   
   # Compare baseline vs broken
   echo "=== Log Comparison ==="
   echo "Baseline errors: $(grep "Errors (EE):" log-analysis-baseline.txt)"
   echo "Broken config errors: $(grep "Errors (EE):" log-analysis-broken.txt)"
   ```

### Questions
1. What do the different log entry markers (II, WW, EE, etc.) indicate?
2. How can you identify driver-related problems in the log?
3. What log entries indicate successful X server startup?

## Exercise 2: Configuration File Generation and Testing (20 minutes)

### Objective
Learn to generate, modify, and test X server configuration files safely.

### Instructions

1. **Generate new configuration file**:
   ```bash
   # Ensure X server is stopped
   sudo systemctl stop display-manager
   sudo pkill X 2>/dev/null || echo "X server not running"
   
   # Generate new configuration
   sudo X -configure
   
   # Examine generated configuration
   ls -la xorg.conf.new
   
   # Analyze the generated configuration
   echo "=== Generated Configuration Analysis ===" > config-analysis.txt
   echo "Sections found:" >> config-analysis.txt
   grep "^Section" xorg.conf.new >> config-analysis.txt
   echo "" >> config-analysis.txt
   
   echo "Device section:" >> config-analysis.txt
   sed -n '/^Section "Device"/,/^EndSection/p' xorg.conf.new >> config-analysis.txt
   echo "" >> config-analysis.txt
   
   echo "Monitor section:" >> config-analysis.txt
   sed -n '/^Section "Monitor"/,/^EndSection/p' xorg.conf.new >> config-analysis.txt
   
   cat config-analysis.txt
   ```

2. **Test configuration safely**:
   ```bash
   # Test the generated configuration
   sudo X -config xorg.conf.new -retro :2 &
   X_PID=$!
   sleep 5
   
   # Check if X server started successfully
   if ps -p $X_PID > /dev/null; then
       echo "X server test: SUCCESS"
       sudo kill $X_PID
   else
       echo "X server test: FAILED"
   fi
   
   # Test with different display number and logging
   sudo X -config xorg.conf.new -logfile /tmp/test-x.log :3 &
   X_TEST_PID=$!
   sleep 3
   sudo kill $X_TEST_PID 2>/dev/null
   
   # Analyze test log
   echo "=== Test Configuration Log ===" >> config-analysis.txt
   grep -E "(EE|WW)" /tmp/test-x.log >> config-analysis.txt
   ```

3. **Create configuration variants for testing**:
   ```bash
   # Create VESA driver configuration
   cp xorg.conf.new xorg.conf.vesa
   sed -i 's/Driver.*".*"/Driver      "vesa"/' xorg.conf.vesa
   
   # Create low resolution configuration
   cp xorg.conf.new xorg.conf.lowres
   sed -i '/Modes/c\        Modes     "800x600" "640x480"' xorg.conf.lowres
   
   # Create 16-bit color depth configuration
   cp xorg.conf.new xorg.conf.16bit
   sed -i 's/DefaultDepth.*/DefaultDepth  16/' xorg.conf.16bit
   
   # Test each variant
   for config in vesa lowres 16bit; do
       echo "Testing $config configuration..."
       sudo X -config xorg.conf.$config -retro :4 &
       TEST_PID=$!
       sleep 3
       if ps -p $TEST_PID > /dev/null; then
           echo "$config test: SUCCESS"
           sudo kill $TEST_PID
       else
           echo "$config test: FAILED"
       fi
   done
   ```

### Questions
1. What command generates a new X server configuration?
2. How do you test a configuration without making it permanent?
3. What are safe methods to test X configurations?

## Exercise 3: Video Driver Troubleshooting (25 minutes)

### Objective
Diagnose and resolve video driver compatibility issues.

### Instructions

1. **Identify current video hardware and drivers**:
   ```bash
   # Check hardware information
   lspci | grep -i vga
   lspci | grep -i display
   
   # Check loaded kernel modules
   lsmod | grep -E "(drm|video|fb)"
   
   # Check available X video drivers
   ls -la /usr/lib/xorg/modules/drivers/
   
   # Document hardware and driver info
   cat > video-driver-info.txt << EOF
   === Video Hardware and Driver Information ===
   Date: $(date)
   
   Hardware:
   $(lspci | grep -i vga)
   $(lspci | grep -i display)
   
   Loaded Kernel Modules:
   $(lsmod | grep -E "(drm|video|fb)" | head -10)
   
   Available X Drivers:
   $(ls /usr/lib/xorg/modules/drivers/ | grep -E ".*_drv.so$" | sed 's/_drv.so//' | sort)
   
   Current X Driver (if configured):
   $(grep -r "Driver" /etc/X11/ 2>/dev/null | head -5)
   EOF
   
   cat video-driver-info.txt
   ```

2. **Simulate "No devices detected" error**:
   ```bash
   # Create configuration with non-existent driver
   cat | sudo tee /etc/X11/xorg.conf << 'EOF'
   Section "Device"
       Identifier  "BadVideoCard"
       Driver      "fakegpu3000"
       BusID       "PCI:99:99:99"
   EndSection
   
   Section "Screen"
       Identifier    "BadScreen"
       Device        "BadVideoCard"
   EndSection
   EOF
   
   # Try to start X and capture the error
   sudo X :5 > /tmp/no-device-error.log 2>&1 &
   X_PID=$!
   sleep 5
   sudo kill $X_PID 2>/dev/null
   
   # Analyze the error
   echo "=== No Devices Detected Error Analysis ===" >> video-driver-info.txt
   grep -E "(EE|Fatal)" /tmp/no-device-error.log >> video-driver-info.txt
   ```

3. **Implement VESA driver fallback**:
   ```bash
   # Create VESA fallback configuration
   cat | sudo tee /etc/X11/xorg.conf << 'EOF'
   Section "Device"
       Identifier  "GenericVideo"
       Driver      "vesa"
   EndSection
   
   Section "Monitor"
       Identifier   "GenericMonitor"
       ModelName    "Generic Monitor"
       HorizSync    28.0-96.0
       VertRefresh  50.0-75.0
   EndSection
   
   Section "Screen"
       Identifier    "GenericScreen"
       Device        "GenericVideo"
       Monitor       "GenericMonitor"
       DefaultDepth  16
       SubSection "Display"
           Depth     16
           Modes     "1024x768" "800x600" "640x480"
       EndSubSection
   EndSection
   EOF
   
   # Test VESA configuration
   sudo X -config /etc/X11/xorg.conf :6 &
   VESA_PID=$!
   sleep 5
   
   if ps -p $VESA_PID > /dev/null; then
       echo "VESA driver test: SUCCESS" >> video-driver-info.txt
       sudo kill $VESA_PID
   else
       echo "VESA driver test: FAILED" >> video-driver-info.txt
   fi
   ```

4. **Create automatic driver detection configuration**:
   ```bash
   # Create auto-detection configuration
   cat | sudo tee /etc/X11/xorg.conf << 'EOF'
   Section "Device"
       Identifier  "AutoDetectVideo"
       Driver      "auto"
   EndSection
   
   Section "Monitor"
       Identifier   "AutoDetectMonitor"
   EndSection
   
   Section "Screen"
       Identifier    "AutoDetectScreen"
       Device        "AutoDetectVideo"
       Monitor       "AutoDetectMonitor"
   EndSection
   EOF
   
   # Test auto-detection
   sudo X -config /etc/X11/xorg.conf :7 &
   AUTO_PID=$!
   sleep 5
   
   if ps -p $AUTO_PID > /dev/null; then
       echo "Auto-detection test: SUCCESS" >> video-driver-info.txt
       sudo kill $AUTO_PID
   else
       echo "Auto-detection test: FAILED" >> video-driver-info.txt
   fi
   
   cat video-driver-info.txt
   ```

### Questions
1. What error message indicates video driver problems?
2. Which driver provides generic compatibility for most video cards?
3. How do you configure automatic driver detection?

## Exercise 4: Display Monitor Compatibility Issues (15 minutes)

### Objective
Resolve display monitor synchronization and compatibility problems.

### Instructions

1. **Simulate monitor compatibility issues**:
   ```bash
   # Create configuration with impossible sync rates
   cat | sudo tee /etc/X11/xorg.conf << 'EOF'
   Section "Device"
       Identifier  "TestVideo"
       Driver      "vesa"
   EndSection
   
   Section "Monitor"
       Identifier   "ImpossibleMonitor"
       ModelName    "Broken Monitor"
       HorizSync    999999.0-999999.0
       VertRefresh  999999.0-999999.0
   EndSection
   
   Section "Screen"
       Identifier    "BadSyncScreen"
       Device        "TestVideo"
       Monitor       "ImpossibleMonitor"
       DefaultDepth  24
       SubSection "Display"
           Depth     24
           Modes     "9999x9999"
       EndSubSection
   EndSection
   EOF
   
   # Test and capture sync error
   sudo X -config /etc/X11/xorg.conf :8 > /tmp/sync-error.log 2>&1 &
   SYNC_PID=$!
   sleep 5
   sudo kill $SYNC_PID 2>/dev/null
   
   echo "=== Monitor Sync Error Analysis ===" > monitor-troubleshooting.txt
   grep -E "(EE|WW)" /tmp/sync-error.log >> monitor-troubleshooting.txt
   ```

2. **Create safe monitor configurations**:
   ```bash
   # Create conservative monitor configuration
   cat | sudo tee /etc/X11/xorg.conf << 'EOF'
   Section "Device"
       Identifier  "SafeVideo"
       Driver      "vesa"
   EndSection
   
   Section "Monitor"
       Identifier   "SafeMonitor"
       ModelName    "Generic Safe Monitor"
       HorizSync    28.0-64.0
       VertRefresh  43.0-60.0
   EndSection
   
   Section "Screen"
       Identifier    "SafeScreen"
       Device        "SafeVideo"
       Monitor       "SafeMonitor"
       DefaultDepth  16
       SubSection "Display"
           Depth     16
           Modes     "800x600" "640x480"
       EndSubSection
   EndSection
   EOF
   
   # Test safe configuration
   sudo X -config /etc/X11/xorg.conf :9 &
   SAFE_PID=$!
   sleep 5
   
   if ps -p $SAFE_PID > /dev/null; then
       echo "Safe monitor config: SUCCESS" >> monitor-troubleshooting.txt
       sudo kill $SAFE_PID
   else
       echo "Safe monitor config: FAILED" >> monitor-troubleshooting.txt
   fi
   ```

3. **Document monitor troubleshooting steps**:
   ```bash
   cat >> monitor-troubleshooting.txt << 'EOF'
   
   === Monitor Troubleshooting Guide ===
   
   Common Issues:
   1. "Screen(s) found, but none have a usable configuration"
   2. Black screen with no cursor
   3. Display flickers or shows distorted image
   
   Solutions:
   1. Use conservative sync rates (28-64 Hz, 43-60 Hz)
   2. Start with low resolution (640x480, 800x600)
   3. Use 16-bit color depth initially
   4. Remove problematic Modes lines
   5. Use generic monitor configuration
   
   Safe Monitor Values:
   - HorizSync: 28.0-64.0
   - VertRefresh: 43.0-60.0
   - Modes: "800x600" "640x480"
   - DefaultDepth: 16
   EOF
   
   cat monitor-troubleshooting.txt
   ```

### Questions
1. What error suggests monitor synchronization problems?
2. What are safe horizontal and vertical sync ranges for troubleshooting?
3. Which screen resolution should you try first when troubleshooting?

## Exercise 5: Font-Related Issues (10 minutes)

### Objective
Diagnose and resolve X server font problems.

### Instructions

1. **Examine font configuration**:
   ```bash
   # Check current font paths
   xset q 2>/dev/null | grep "Font Path" || echo "X not running in current session"
   
   # Check FontConfig status
   fc-list | head -5
   fc-cache -v 2>&1 | head -10
   
   # Check X server built-in fonts
   ls -la /usr/share/fonts/ | head -10
   ```

2. **Simulate font problems**:
   ```bash
   # Create configuration with bad font paths
   cat | sudo tee /etc/X11/xorg.conf << 'EOF'
   Section "Files"
       FontPath     "/nonexistent/fonts/path"
       FontPath     "/another/bad/path"
   EndSection
   
   Section "Device"
       Identifier  "TestVideo"
       Driver      "vesa"
   EndSection
   
   Section "Screen"
       Identifier    "TestScreen"
       Device        "TestVideo"
   EndSection
   EOF
   
   # Test with bad font paths
   sudo X -config /etc/X11/xorg.conf :10 > /tmp/font-error.log 2>&1 &
   FONT_PID=$!
   sleep 5
   sudo kill $FONT_PID 2>/dev/null
   
   echo "=== Font Error Analysis ===" > font-troubleshooting.txt
   grep -i font /tmp/font-error.log >> font-troubleshooting.txt
   ```

3. **Create working font configuration**:
   ```bash
   # Create modern font configuration
   cat | sudo tee /etc/X11/xorg.conf << 'EOF'
   Section "Files"
       ModulePath   "/usr/lib/xorg/modules"
       FontPath     "catalogue:/etc/X11/fontpath.d"
       FontPath     "built-ins"
   EndSection
   
   Section "Device"
       Identifier  "TestVideo"
       Driver      "vesa"
   EndSection
   
   Section "Screen"
       Identifier    "TestScreen"
       Device        "TestVideo"
   EndSection
   EOF
   
   # Test working font configuration
   sudo X -config /etc/X11/xorg.conf :11 &
   WORKING_FONT_PID=$!
   sleep 5
   
   if ps -p $WORKING_FONT_PID > /dev/null; then
       echo "Working font config: SUCCESS" >> font-troubleshooting.txt
       sudo kill $WORKING_FONT_PID
   else
       echo "Working font config: FAILED" >> font-troubleshooting.txt
   fi
   
   # Document font configuration
   cat >> font-troubleshooting.txt << 'EOF'
   
   === Font Configuration Guide ===
   
   Modern Font Configuration:
   FontPath "catalogue:/etc/X11/fontpath.d"
   FontPath "built-ins"
   
   Legacy Font Configuration:
   FontPath "/usr/share/fonts/X11/misc/"
   FontPath "/usr/share/fonts/X11/75dpi/:unscaled"
   FontPath "/usr/share/fonts/X11/100dpi/:unscaled"
   
   Font Cache Commands:
   fc-cache -f -v
   fc-list | head -10
   EOF
   
   cat font-troubleshooting.txt
   ```

### Questions
1. What are the modern font path configurations for X server?
2. How do you rebuild the font cache?
3. What font paths are considered legacy?

## Lab Completion Tasks

### Task 1: Create Comprehensive Troubleshooting Guide
Create a complete troubleshooting methodology:

```bash
cat > x-troubleshooting-guide.txt << 'EOF'
=== X Server Troubleshooting Methodology ===

1. INITIAL ASSESSMENT
   - Check X server log: tail -50 /var/log/Xorg.0.log
   - Identify error markers: grep -E "(EE|Fatal)" /var/log/Xorg.0.log
   - Note warnings: grep "^(WW)" /var/log/Xorg.0.log

2. BACKUP CURRENT CONFIGURATION
   - cp /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
   - cp /etc/X11/default-display-manager /etc/X11/default-display-manager.backup

3. ACCESS ALTERNATIVE CONSOLE
   - Ctrl+Alt+F2 (or F1-F6)
   - SSH into system if network available
   - Boot in single-user mode if needed

4. SYSTEMATIC TESTING

   Step A: Test with no configuration (auto-detect)
   - mv /etc/X11/xorg.conf /etc/X11/xorg.conf.disabled
   - startx

   Step B: Generate new configuration
   - X -configure
   - cp xorg.conf.new /etc/X11/xorg.conf
   - startx

   Step C: Use VESA driver fallback
   - Edit xorg.conf: Driver "vesa"
   - DefaultDepth 16
   - Modes "800x600" "640x480"

   Step D: Minimal configuration
   - Remove problematic sections
   - Use conservative settings
   - Test incrementally

5. SPECIFIC PROBLEM RESOLUTION

   Video Driver Issues:
   - lspci | grep -i vga
   - Use "vesa" driver
   - Check available drivers: ls /usr/lib/xorg/modules/drivers/

   Monitor Sync Issues:
   - Use safe sync rates: HorizSync 28-64, VertRefresh 43-60
   - Start with 640x480 resolution
   - Use 16-bit color depth

   Font Issues:
   - Use modern font paths
   - FontPath "built-ins"
   - fc-cache -f -v

6. VERIFICATION
   - X server starts without errors
   - Display manager loads properly
   - Basic GUI functionality works
   - Log file shows no critical errors

7. DOCUMENTATION
   - Document working configuration
   - Note specific hardware requirements
   - Keep backup of working config
EOF

cat x-troubleshooting-guide.txt
```

### Task 2: Create Emergency Recovery Scripts
Create scripts for quick recovery:

```bash
# Emergency X server recovery script
cat > emergency-x-recovery.sh << 'EOF'
#!/bin/bash
# Emergency X Server Recovery Script

echo "=== X Server Emergency Recovery ==="
echo "Date: $(date)"

# Stop X server and display manager
echo "Stopping X server and display manager..."
sudo systemctl stop display-manager
sudo pkill X 2>/dev/null

# Backup current configuration
echo "Backing up current configuration..."
sudo cp /etc/X11/xorg.conf "/etc/X11/xorg.conf.emergency.$(date +%Y%m%d_%H%M%S)" 2>/dev/null

# Create minimal working configuration
echo "Creating minimal working configuration..."
cat | sudo tee /etc/X11/xorg.conf << 'XEOF'
Section "Device"
    Identifier  "EmergencyVideo"
    Driver      "vesa"
EndSection

Section "Monitor"
    Identifier   "EmergencyMonitor"
    HorizSync    28.0-64.0
    VertRefresh  43.0-60.0
EndSection

Section "Screen"
    Identifier    "EmergencyScreen"
    Device        "EmergencyVideo"
    Monitor       "EmergencyMonitor"
    DefaultDepth  16
    SubSection "Display"
        Depth     16
        Modes     "800x600" "640x480"
    EndSubSection
EndSection

Section "Files"
    FontPath     "built-ins"
EndSection
XEOF

# Test the configuration
echo "Testing emergency configuration..."
sudo X -config /etc/X11/xorg.conf :99 &
TEST_PID=$!
sleep 5

if ps -p $TEST_PID > /dev/null; then
    echo "Emergency configuration: SUCCESS"
    sudo kill $TEST_PID
    echo "Starting display manager..."
    sudo systemctl start display-manager
else
    echo "Emergency configuration: FAILED"
    echo "Removing configuration file for auto-detection..."
    sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.failed
    sudo systemctl start display-manager
fi

echo "Recovery complete. Check system status."
EOF

chmod +x emergency-x-recovery.sh
```

### Task 3: Test All Troubleshooting Scenarios
Run comprehensive tests:

```bash
# Create test suite
cat > test-troubleshooting.sh << 'EOF'
#!/bin/bash
# X Server Troubleshooting Test Suite

echo "=== X Server Troubleshooting Test Suite ===" > test-results.txt
echo "Date: $(date)" >> test-results.txt
echo "" >> test-results.txt

# Test 1: Auto-detection
echo "Test 1: Auto-detection" >> test-results.txt
sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.test 2>/dev/null
sudo X :98 &
sleep 3
if ps aux | grep -q "X.*:98"; then
    echo "  Result: SUCCESS" >> test-results.txt
    sudo pkill -f "X.*:98"
else
    echo "  Result: FAILED" >> test-results.txt
fi

# Test 2: VESA driver
echo "Test 2: VESA driver fallback" >> test-results.txt
cat | sudo tee /etc/X11/xorg.conf << 'TESTEOF'
Section "Device"
    Identifier  "TestVesa"
    Driver      "vesa"
EndSection
TESTEOF

sudo X -config /etc/X11/xorg.conf :97 &
sleep 3
if ps aux | grep -q "X.*:97"; then
    echo "  Result: SUCCESS" >> test-results.txt
    sudo pkill -f "X.*:97"
else
    echo "  Result: FAILED" >> test-results.txt
fi

# Restore configuration
sudo mv /etc/X11/xorg.conf.test /etc/X11/xorg.conf 2>/dev/null

echo "Test suite completed. Results:"
cat test-results.txt
EOF

chmod +x test-troubleshooting.sh
./test-troubleshooting.sh
```

## Verification and Cleanup

1. **Verify troubleshooting knowledge**:
   ```bash
   # Test log analysis skills
   ./analyze-xorg-log.sh > final-log-analysis.txt
   
   # Verify recovery procedures work
   ./emergency-x-recovery.sh
   
   # Check system is functional
   systemctl status display-manager
   ```

2. **Restore working configuration**:
   ```bash
   # Restore original configuration
   sudo cp ~/lab-backups/lab3/xorg.conf.working /etc/X11/xorg.conf 2>/dev/null || sudo rm /etc/X11/xorg.conf
   sudo cp ~/lab-backups/lab3/default-display-manager.working /etc/X11/default-display-manager
   
   # Restart display manager
   sudo systemctl restart display-manager
   ```

3. **Archive troubleshooting materials**:
   ```bash
   # Create comprehensive archive
   mkdir -p ~/lab-results/lab3
   cp *.txt *.sh ~/lab-results/lab3/
   
   # Mark lab complete
   echo "Lab 3 completed: $(date)" >> ~/lab-progress/completed.log
   echo "Advanced X Server troubleshooting skills acquired" >> ~/lab-progress/completed.log
   ```

## Troubleshooting This Lab

### If X Server Won't Start at All
```bash
# Use the emergency recovery script
./emergency-x-recovery.sh

# Or manually reset
sudo rm /etc/X11/xorg.conf
sudo systemctl restart display-manager
```

### If System Becomes Unresponsive
```bash
# Access via SSH
vagrant ssh

# Or reboot the VM
vagrant reload
```

### If Logs Are Unclear
```bash
# Generate fresh logs
sudo systemctl stop display-manager
sudo rm /var/log/Xorg.0.log
sudo X :1 > /tmp/fresh-x.log 2>&1 &
sleep 5
sudo pkill -f "X.*:1"
cat /tmp/fresh-x.log
```

## Next Steps

After completing Lab 3, you should:

1. **Be confident in X server troubleshooting**
2. **Understand systematic debugging approaches**
3. **Know how to create recovery procedures**
4. **Proceed to Lab 4** which covers advanced font management and configuration

## Additional Resources

- X.Org Troubleshooting: http://www.x.org/wiki/FAQErrorMessages
- X Server Log Analysis: `man Xorg`
- VESA Driver Documentation: `man vesa`

---

**Lab 3 Complete!** ✅

You now have advanced X server troubleshooting skills and can diagnose and resolve common X Window issues. In Lab 4, you'll learn advanced font management and configuration techniques.