#!/bin/bash

for cmd in rm update-mime-database sed echo; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
        exit 1
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

if ! command -v "/usr/ProgramFiles/appimagekit/AppRun" &> /dev/null; then
    echo "AppImage Tools is Not Installed, So Cancelling Removal." >&2
    exit 1
else
    echo "Removing AppImage Tools..."
fi

rm -rf "/usr/share/icons/hicolor/128x128/apps/appimagetool.png" "/usr/share/applications/appimagetool.desktop" "/usr/ProgramFiles/appimagekit" "/usr/bin/appimagetool"

echo "AppImage Tools has been Removed Successfully."
