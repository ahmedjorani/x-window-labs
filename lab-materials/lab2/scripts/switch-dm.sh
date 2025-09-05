# =================================================================
# File: lab-materials/lab2/scripts/switch-dm.sh
# =================================================================
#!/bin/bash
# Display Manager Switching Script

CURRENT_DM=$(basename $(cat /etc/X11/default-display-manager 2>/dev/null))

echo "=== Display Manager Switcher ==="
echo "Current Display Manager: $CURRENT_DM"
echo ""
echo "Available Display Managers:"

DM_LIST=($(ls /usr/sbin/*dm 2>/dev/null | grep -E "(lightdm|gdm|sddm|xdm)"))
for i in "${!DM_LIST[@]}"; do
    echo "$((i+1)). $(basename ${DM_LIST[$i]})"
done

echo ""
read -p "Select display manager (1-${#DM_LIST[@]}): " choice

if [[ $choice -ge 1 && $choice -le ${#DM_LIST[@]} ]]; then
    selected_dm=${DM_LIST[$((choice-1))]}
    echo "Switching to $(basename $selected_dm)..."
    
    # Backup current setting
    sudo cp /etc/X11/default-display-manager /etc/X11/default-display-manager.backup
    
    # Set new display manager
    echo "$selected_dm" | sudo tee /etc/X11/default-display-manager
    
    # Restart display manager
    sudo systemctl restart display-manager
    
    echo "Display manager switched successfully!"
else
    echo "Invalid selection"
    exit 1
fi
