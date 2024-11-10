#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

for cmd in sed rm update-desktop-database echo; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
    exit 1
  fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

if ! command -v "/usr/lib/ventoy/VentoyGUI.x86_64" &> /dev/null; then
    echo "Ventoy is Not Installed, So Cancelling Removal."
    exit 1
elif ! command -v "/usr/lib/ventoy/VentoyGUI.i386" &> /dev/null; then
    echo "Ventoy is Not Installed, So Cancelling Removal."
    exit 1
elif ! command -v "/usr/lib/ventoy/VentoyGUI.aarch64" &> /dev/null; then
    echo "Ventoy is Not Installed, So Cancelling Removal."
    exit 1
elif ! command -v "/usr/lib/ventoy/VentoyGUI.mips64el" &> /dev/null; then
    echo "Ventoy is Not Installed, So Cancelling Removal."
    exit 1
else
    echo "Remove Ventoy..."
    rm -rf "/usr/share/applications/ventoy.desktop" "/usr/lib/ventoy" "/usr/bin/cpi" "/usr/bin/epi" "/usr/bin/vp" "/usr/bin/vw" "/usr/bin/vv" "/usr/bin/v2d" "/usr/bin/ventoyedit"

    for file in $(find /usr/share/icons/hicolor/* -name "ventoy.*"); do
        rm -rf "$file"
    done

    update-desktop-database

    echo "Ventoy has been Removed Successfully."

    exit 1
fi

