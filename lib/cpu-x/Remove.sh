#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

if ! command -v "/usr/ProgramFiles/cpu-x/bin/cpu-x" &> /dev/null; then
    echo "CPU-X Is Not Installed, so Cancelling Removed."
    exit 1
else
    echo "Remove CPU-X..."
    rm -rf "/usr/share/applications/cpu-x.desktop" "/usr/share/icons/hicolor/16x16/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/22x22/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/24x24/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/32x32/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/36x36/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/48x48/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/64x64/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/72x72/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/96x96/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/128x128/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/192x192/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/256x256/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/384x384/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/512x512/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/scalable/apps/io.github.thetumultuousunicornofdarkness.cpu-x.svg" "/usr/ProgramFiles/cpu-x" "/usr/bin/cpu-x"
    exit 1
fi

echo "CPU-X has been Removed successfully."
