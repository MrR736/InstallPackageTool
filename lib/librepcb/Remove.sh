#!/bin/bash

librepcb_BIN="/usr/ProgramFiles/librepcb/bin/librepcb"
cd "$(dirname "${BASH_SOURCE[0]}")"

for cmd in sed rm update-mime-database echo; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
    exit 1
  fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

if ! command -v librepcb &> /dev/null; then
    echo "Librepcb is Not Installed, So Cancelling Removal."
    exit 1
else
    echo "Remove Librepcb..."
    if command -v apt &> /dev/null; then
        if ! sudo apt remove librepcb &> /dev/null; then
            echo -e "\e[31mE: Failed To Remove LibrePCB using apt.\e[0m" >&2
        fi
    elif command -v dnf &> /dev/null; then
        if ! sudo dnf remove librepcb &> /dev/null; then
            echo -e "\e[31mE: Failed To Remove LibrePCB using dnf.\e[0m" >&2
        fi
    elif command -v yum &> /dev/null; then
        if ! sudo yum remove librepcb &> /dev/null; then
            echo -e "\e[31mE: Failed To Remove LibrePCB using yum.\e[0m" >&2
        fi
    elif command -v snap &> /dev/null; then
        if ! sudo snap remove librepcb &> /dev/null; then
            echo -e "\e[31mE: Failed To Remove LibrePCB using snap.\e[0m" >&2
        fi
    elif command -v nix-shell &> /dev/null &> /dev/null; then
        if ! nix-shell -r librepcb; then
            echo -e "\e[31mE: Failed To Remove LibrePCB using nix-shell.\e[0m" >&2
        fi
    elif command -v flatpak &> /dev/null; then
        if ! flatpak remove flathub org.librepcb.LibrePCB &> /dev/null; then
            echo -e "\e[31mE: Failed To Remove LibrePCB using flatpak.\e[0m" >&2
        fi
    else
        echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
    fi

    rm -rf "/usr/bin/librepcb" "/usr/bin/librepcb-cli" "/usr/share/icons/hicolor/16x16/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/24x24/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/32x32/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/48x48/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/64x64/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/128x128/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/scalable/apps/org.librepcb.LibrePCB.svg" "/usr/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-archive.svg" "/usr/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-file.svg" "/usr/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-project.svg" "/usr/share/librepcb" "/usr/librepcb" "/usr/share/metainfo/org.librepcb.LibrePCB.metainfo.xml" "/usr/share/mime/packages/org.librepcb.LibrePCB.xml" "/usr/share/applications/org.librepcb.LibrePCB.desktop" "/usr/ProgramFiles/librepcb" "$HOME/.config/LibrePCB" "/usr/share/doc/librepcb"

    sed -i '/application\/x-librepcb-file/d' /usr/share/mime/types
    sed -i '/application\/x-librepcb-project/d' /usr/share/mime/types
    sed -i '/application\/x-librepcb-project-archive/d' /usr/share/mime/types

    sed -i '/application\/x-librepcb-file/d' /usr/share/mime/icons
    sed -i '/application\/x-librepcb-project/d' /usr/share/mime/icons
    sed -i '/application\/x-librepcb-project-archive/d' /usr/share/mime/icons

    sed -i '/application\/x-librepcb-file text\/plain/d' /usr/share/mime/subclasses
    sed -i '/application\/x-librepcb-project text\/plain/d' /usr/share/mime/subclasses
    sed -i '/application\/x-librepcb-project-archive application\/zip/d' /usr/share/mime/subclasses

    update-mime-database /usr/share/mime

    echo "Librepcb has been Removed Successfully."

    exit 1
fi

