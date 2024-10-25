#!/bin/bash

librepcb_BIN="/usr/ProgramFiles/librepcb/bin/librepcb"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m"
    exit 1
fi

for cmd in sed rm update-mime-database echo; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "\e[31mE: $cmd Is Not Installed.\e[0m"
    exit 1
  fi
done

if [[ ! -e "$librepcb_BIN" ]]; then
    echo "Librepcb is Already Installed, so Cancelling Installation."
    exit 1
else
    echo "Remove Librepcb..."
    rm -rf "/usr/bin/librepcb" "/usr/bin/librepcb-cli" "/usr/share/icons/hicolor/16x16/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/24x24/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/32x32/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/48x48/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/64x64/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/128x128/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/scalable/apps/org.librepcb.LibrePCB.svg" "/usr/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-archive.svg" "/usr/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-file.svg" "/usr/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-project.svg" "/usr/share/librepcb" "/usr/librepcb" "/usr/share/metainfo/org.librepcb.LibrePCB.metainfo.xml" "/usr/share/mime/packages/org.librepcb.LibrePCB.xml" "/usr/share/applications/org.librepcb.LibrePCB.desktop" "/usr/ProgramFiles/librepcb" "~/.config/LibrePCB"
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

    echo "Librepcb has been Removed successfully."

    exit 1
fi

