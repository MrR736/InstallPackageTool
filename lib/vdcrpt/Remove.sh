#!/bin/bash

for cmd in rm update-desktop-database echo; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
        exit 1
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

if ! command -v "/usr/ProgramFiles/vdcrpt/bin/vdcrpt" &> /dev/null; then
    echo "VdCrpt is Not Installed, So Cancelling Removal."
    exit 1
else
    echo "Removing VdCrpt..."
fi

rm -rf "/usr/share/applications/vdcrpt.desktop" "/usr/share/icons/hicolor/256x256/apps/vdcrpt.png" "/usr/ProgramFiles/vdcrpt" "/usr/bin/vdcrpt"

update-desktop-database

echo "VdCrpt has been Removed successfully."
