#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

remove_blockbench() {
echo "Remove Blockbench..."
if command -v apt &> /dev/null && command -v "/opt/Blockbench/blockbench" &> /dev/null; then
    apt autoremove blockbench &> /dev/null
elif command -v dnf &> /dev/null && command -v "/opt/Blockbench/blockbench" &> /dev/null; then
    dnf remove blockbench &> /dev/null
elif command -v yum &> /dev/null && command -v "/opt/Blockbench/blockbench" &> /dev/null; then
    yum remove blockbench &> /dev/null
elif command -v "/usr/ProgramFiles/blockbench/bin/blockbench" &> /dev/null; then
    rm -rf "$HOME/.config/Blockbench" "/usr/share/applications/blockbench.desktop" "/usr/share/doc/blockbench" "/usr/share/icons/hicolor/16x16/apps/blockbench.png" "/usr/share/icons/hicolor/32x32/apps/blockbench.png" "/usr/share/icons/hicolor/48x48/apps/blockbench.png" "/usr/share/icons/hicolor/64x64/apps/blockbench.png" "/usr/share/icons/hicolor/128x128/apps/blockbench.png" "/usr/share/icons/hicolor/256x256/apps/blockbench.png" "/usr/share/icons/hicolor/512x512/apps/blockbench.png" "/usr/share/mime/packages/blockbench.xml" "/usr/bin/blockbench" "/usr/ProgramFiles/blockbench"
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
    exit 1
fi

echo "Blockbench has been Removed successfully."
}

if command -v blockbench &> /dev/null; then
    remove_blockbench
else
    echo "Blockbench Is Not Installed, so Cancelling Removed."
    exit 1
fi
