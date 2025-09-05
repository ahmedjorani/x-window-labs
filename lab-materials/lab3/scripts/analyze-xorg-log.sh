# =================================================================
# File: lab-materials/lab3/scripts/analyze-xorg-log.sh
# =================================================================
#!/bin/bash
# X Server Log Analysis Script

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