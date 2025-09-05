# =================================================================
# File: lab-materials/lab3/scripts/emergency-recovery.sh
# =================================================================
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
cat | sudo tee /etc/X11/xorg.conf << 'EOF'
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
EOF

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