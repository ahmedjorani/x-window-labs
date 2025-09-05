# Lab 1: X Window Components and Basic Configuration

## Lab Information
- **Duration**: 60 minutes
- **Difficulty**: Beginner
- **Chapter Reference**: 3.1, 3.2, 3.3.1-3.3.3

## Learning Objectives
By the end of this lab, you will be able to:

✅ **Identify X Window system components and their roles**
✅ **Examine and understand X server processes and configuration**
✅ **Navigate X Window configuration files and directories**
✅ **Start and stop X services manually**
✅ **Understand runlevels and their impact on X Window**
✅ **Configure basic X server settings**
✅ **Test X Window functionality in different modes**

## Prerequisites
- Access to the lab VM via `vagrant ssh`
- Basic Linux command-line knowledge
- Sudo privileges on the lab system

## Lab Environment Setup

1. **Access the lab environment**:
   ```bash
   vagrant ssh
   cd lab-materials/lab1
   ```

2. **Verify environment**:
   ```bash
   # Check if X Window components are installed
   which X
   which startx
   ls -la /etc/X11/
   ```

## Exercise 1: Exploring X Window Components (15 minutes)

### Objective
Identify and examine the core X Window system components on your system.

### Instructions

1. **Examine X Server executable**:
   ```bash
   # Find the X server
   which X
   
   # Check X server version and capabilities
   X -version
   
   # List X server modules
   ls -la /usr/lib/xorg/modules/
   ```

2. **Identify installed display managers**:
   ```bash
   # Check available display managers
   ls -la /usr/sbin/*dm
   
   # Check current default display manager
   cat /etc/X11/default-display-manager
   
   # Check display manager status
   systemctl status display-manager
   ```

3. **Examine input and video drivers**:
   ```bash
   # List video drivers
   ls -la /usr/lib/xorg/modules/drivers/
   
   # List input drivers  
   ls -la /usr/lib/xorg/modules/input/
   
   # Check currently loaded modules
   lsmod | grep -E "(drm|video|input)"
   ```

4. **Document your findings**:
   ```bash
   # Create a component inventory
   cat > component-inventory.txt << EOF
   X Server Version: $(X -version 2>&1 | head -1)
   Default Display Manager: $(cat /etc/X11/default-display-manager)
   Available Video Drivers: $(ls /usr/lib/xorg/modules/drivers/ | wc -l) drivers
   Available Input Drivers: $(ls /usr/lib/xorg/modules/input/ | wc -l) drivers
   EOF
   
   cat component-inventory.txt
   ```

### Questions
1. What version of X server is installed?
2. Which display manager is currently configured as default?
3. How many video drivers are available on your system?

## Exercise 2: Understanding X Server Processes (15 minutes)

### Objective
Learn how to identify, monitor, and control X server processes.

### Instructions

1. **Check current X server status**:
   ```bash
   # Check if X is running
   ps aux | grep X | grep -v grep
   
   # Check X server listening ports
   ss -tuln | grep ":60"
   
   # Check display environment variables
   echo $DISPLAY
   ```

2. **Examine X server in different runlevels**:
   ```bash
   # Check current runlevel
   runlevel
   who -r
   
   # Check systemd target
   systemctl get-default
   
   # List active display-related services
   systemctl list-units | grep -E "(display|graphical|x11)"
   ```

3. **Start X server manually**:
   ```bash
   # Switch to console mode (if in GUI)
   sudo systemctl stop display-manager
   
   # Check that X is stopped
   ps aux | grep X | grep -v grep
   
   # Start X manually
   sudo startx &
   
   # Check X process again
   ps aux | grep X | grep -v grep
   
   # Stop X manually
   sudo pkill X
   ```

4. **Monitor X server startup**:
   ```bash
   # Watch X server logs during startup
   sudo tail -f /var/log/Xorg.0.log &
   
   # Start X in another terminal
   sudo startx
   
   # Stop the tail command
   sudo pkill tail
   ```

### Questions
1. What process ID (PID) does the X server have when running?
2. What display number is typically used for the primary X server?
3. Which port does the X server listen on?

## Exercise 3: X Window Configuration Files (20 minutes)

### Objective
Explore and understand X Window configuration file structure and contents.

### Instructions

1. **Examine configuration directories**:
   ```bash
   # Main X11 configuration directory
   ls -la /etc/X11/
   
   # Check for main configuration file
   ls -la /etc/X11/xorg.conf*
   
   # Check configuration fragments directory
   ls -la /etc/X11/xorg.conf.d/
   ```

2. **Generate a basic X configuration**:
   ```bash
   # Stop X server if running
   sudo systemctl stop display-manager
   
   # Generate configuration file
   sudo X -configure
   
   # Check generated file
   ls -la xorg.conf.new
   cat xorg.conf.new
   ```

3. **Analyze configuration sections**:
   ```bash
   # Extract different sections
   grep -n "^Section" xorg.conf.new
   
   # View specific sections
   sed -n '/Section "Device"/,/EndSection/p' xorg.conf.new
   sed -n '/Section "Screen"/,/EndSection/p' xorg.conf.new
   sed -n '/Section "Monitor"/,/EndSection/p' xorg.conf.new
   ```

4. **Create a backup and test configuration**:
   ```bash
   # Backup any existing configuration
   sudo cp /etc/X11/xorg.conf /etc/X11/xorg.conf.backup 2>/dev/null || echo "No existing xorg.conf"
   
   # Copy generated configuration
   sudo cp xorg.conf.new /etc/X11/xorg.conf
   
   # Test the configuration
   sudo X -config /etc/X11/xorg.conf -retro &
   sleep 5
   sudo pkill X
   ```

5. **Examine configuration file contents**:
   ```bash
   # Count sections in configuration
   grep "^Section" /etc/X11/xorg.conf | wc -l
   
   # List all section types
   grep "^Section" /etc/X11/xorg.conf | sort | uniq
   
   # Find specific configuration items
   grep -E "Driver|Device|Monitor" /etc/X11/xorg.conf
   ```

### Questions
1. How many sections does your generated xorg.conf file contain?
2. What video driver is specified in the Device section?
3. What is the default color depth configured?

## Exercise 4: Runlevel and X Window Control (10 minutes)

### Objective
Understand how runlevels affect X Window startup and learn manual control methods.

### Instructions

1. **Examine current system target**:
   ```bash
   # Check current target
   systemctl get-default
   
   # List available targets
   systemctl list-units --type=target
   
   # Check graphical target dependencies
   systemctl list-dependencies graphical.target
   ```

2. **Switch between graphical and text modes**:
   ```bash
   # Switch to multi-user target (text mode)
   sudo systemctl isolate multi-user.target
   
   # Check current mode
   systemctl get-default
   ps aux | grep X | grep -v grep
   
   # Switch back to graphical target
   sudo systemctl isolate graphical.target
   
   # Verify X is running
   ps aux | grep X | grep -v grep
   ```

3. **Test single-user mode access**:
   ```bash
   # Note: This is for understanding - don't actually switch to single-user mode
   echo "To boot in single-user mode, add '1' or 'single' to kernel parameters"
   echo "Example: linux /boot/vmlinuz root=/dev/sda1 ro single"
   
   # Check single-user target
   systemctl show rescue.target
   ```

4. **Control display manager service**:
   ```bash
   # Check display manager service status
   systemctl status display-manager
   
   # Stop display manager
   sudo systemctl stop display-manager
   
   # Check X server status
   ps aux | grep X | grep -v grep
   
   # Restart display manager
   sudo systemctl start display-manager
   ```

### Questions
1. What is the default systemd target on your system?
2. What happens to the X server when you stop the display manager?
3. How would you permanently set the system to boot in text mode?

## Lab Completion Tasks

### Task 1: Create Configuration Summary
Create a summary file of your system's X Window configuration:

```bash
cat > x-window-summary.txt << EOF
=== X Window System Summary ===
Date: $(date)
User: $(whoami)

X Server Version: $(X -version 2>&1 | head -1)
Default Target: $(systemctl get-default)
Display Manager: $(basename $(cat /etc/X11/default-display-manager))
Configuration File: $(ls /etc/X11/xorg.conf 2>/dev/null || echo "Auto-configured")

Available Desktop Environments:
$(ls /usr/share/xsessions/ 2>/dev/null | grep .desktop | cut -d. -f1 || echo "None found")

Video Drivers Available: $(ls /usr/lib/xorg/modules/drivers/ | wc -l)
Input Drivers Available: $(ls /usr/lib/xorg/modules/input/ | wc -l)

Current X Process:
$(ps aux | grep X | grep -v grep | head -1 || echo "X server not running")
EOF

cat x-window-summary.txt
```

### Task 2: Test Configuration Changes
Make a simple configuration change and test it:

```bash
# Create a test configuration with specific resolution
sudo cp /etc/X11/xorg.conf /etc/X11/xorg.conf.lab1.backup

# Modify Screen section to include specific modes
sudo sed -i '/Section "Screen"/,/EndSection/{
    s/Modes.*/Modes     "1024x768" "800x600" "640x480"/
}' /etc/X11/xorg.conf

# Test the configuration
sudo X -config /etc/X11/xorg.conf -retro &
sleep 3
sudo pkill X

# Restore original configuration
sudo cp /etc/X11/xorg.conf.lab1.backup /etc/X11/xorg.conf
```

### Task 3: Document Learning Outcomes
Answer these questions in a file called `lab1-answers.txt`:

```bash
cat > lab1-answers.txt << EOF
Lab 1 Completion - $(date)

1. List the main X Window components and their functions:

2. What is the relationship between the X server and X clients?

3. How does the display manager relate to the X server?

4. What configuration files control X Window behavior?

5. How do you manually start and stop the X server?

6. What happens when you change the system target from graphical to multi-user?

7. What information can you find in /var/log/Xorg.0.log?

8. How would you troubleshoot an X server that won't start?
EOF

# Edit the file to add your answers
nano lab1-answers.txt
```

## Verification and Cleanup

1. **Verify lab completion**:
   ```bash
   # Check that required files exist
   ls -la component-inventory.txt x-window-summary.txt lab1-answers.txt
   
   # Verify X server is running properly
   systemctl status display-manager
   ps aux | grep X | grep -v grep
   ```

2. **Clean up temporary files**:
   ```bash
   # Remove generated configuration
   rm -f xorg.conf.new
   
   # Keep important files for reference
   mkdir -p ~/lab-results/lab1
   cp *.txt ~/lab-results/lab1/
   
   # Mark lab as complete
   echo "Lab 1 completed: $(date)" >> ~/lab-progress/completed.log
   ```

3. **Restart display manager if needed**:
   ```bash
   sudo systemctl restart display-manager
   ```

## Troubleshooting Common Issues

### X Server Won't Start
```bash
# Check logs for errors
sudo tail -20 /var/log/Xorg.0.log | grep -E "(EE|WW)"

# Test with VESA driver
sudo sed -i 's/Driver.*/Driver      "vesa"/' /etc/X11/xorg.conf
sudo startx
```

### Configuration File Issues
```bash
# Generate new configuration
sudo X -configure
sudo cp xorg.conf.new /etc/X11/xorg.conf

# Or remove configuration for auto-detection
sudo mv /etc/X11/xorg.conf /etc/X11/xorg.conf.disabled
```

### Permission Issues
```bash
# Fix X11 permissions
sudo chmod 755 /etc/X11
sudo chmod 644 /etc/X11/xorg.conf
```

## Next Steps

After completing Lab 1, you should:

1. **Review your answers** and ensure you understand each concept
2. **Proceed to Lab 2** which covers Display Manager Configuration
3. **Keep your configuration files** for reference in future labs

## Additional Resources

- X.org Configuration Documentation: https://www.x.org/releases/current/doc/man/man5/xorg.conf.5.xhtml
- X Server Manual: `man X`
- Xorg Manual: `man xorg`

---

**Lab 1 Complete!** ✅

You now understand the basic components of the X Window system and how to configure them. In Lab 2, you'll learn to configure and manage different display managers.