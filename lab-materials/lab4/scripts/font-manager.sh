# =================================================================
# File: lab-materials/lab4/scripts/font-manager.sh
# =================================================================
#!/bin/bash
# Font Management Script

show_menu() {
    echo "=== Font Management Tool ==="
    echo "1. List all fonts"
    echo "2. Install font (system)"
    echo "3. Install font (user)"
    echo "4. Rebuild font cache"
    echo "5. Test font matching"
    echo "6. Show font information"
    echo "7. Exit"
    echo ""
    read -p "Select option (1-7): " choice
}

list_fonts() {
    echo "Total fonts available: $(fc-list | wc -l)"
    echo ""
    echo "Font families (first 20):"
    fc-list : family | sort | uniq | head -20
}

install_system_font() {
    read -p "Enter path to font file: " font_path
    if [ -f "$font_path" ]; then
        sudo cp "$font_path" /usr/share/fonts/truetype/
        sudo fc-cache -f -v
        echo "Font installed system-wide"
    else
        echo "Font file not found"
    fi
}

install_user_font() {
    read -p "Enter path to font file: " font_path
    if [ -f "$font_path" ]; then
        mkdir -p ~/.fonts
        cp "$font_path" ~/.fonts/
        fc-cache -f ~/.fonts
        echo "Font installed for user"
    else
        echo "Font file not found"
    fi
}

rebuild_cache() {
    echo "Rebuilding font cache..."
    fc-cache -f -v
    echo "Font cache rebuilt"
}

test_matching() {
    echo "Testing font matching:"
    echo "Serif: $(fc-match serif)"
    echo "Sans-serif: $(fc-match sans-serif)"
    echo "Monospace: $(fc-match monospace)"
}

font_info() {
    read -p "Enter font name or path: " font_input
    fc-query "$font_input" 2>/dev/null || fc-list | grep -i "$font_input"
}

# Main loop
while true; do
    show_menu
    case $choice in
        1) list_fonts ;;
        2) install_system_font ;;
        3) install_user_font ;;
        4) rebuild_cache ;;
        5) test_matching ;;
        6) font_info ;;
        7) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option" ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
done
