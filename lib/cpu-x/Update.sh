#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

if ! command -v "/usr/ProgramFiles/cpu-x/bin/cpu-x" &> /dev/null; then
    exit 1
fi

for cmd in curl chmod sed mkdir read awk wget grep tee ln rm "$ZZ_BIN"; do
    if ! command -v "$cmd" &> /dev/null; then
        if [[ "$ZZ_BIN" != "$cmd" ]]; then
            echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
            exit 1
        else
            echo -e "\e[31mE: 7zz Is Not Installed.\e[0m" >&2
            exit 1
        fi
    fi
done

Cpu_X_LATEST_VERSION=$(curl -s https://api.github.com/repos/TheTumultuousUnicornOfDarkness/CPU-X/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

remove_cpu-x_appimage() {
if command -v "/usr/ProgramFiles/cpu-x/bin/cpu-x" &> /dev/null; then
    rm -rf "/usr/share/applications/cpu-x.desktop" "/usr/share/icons/hicolor/16x16/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/22x22/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/24x24/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/32x32/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/36x36/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/48x48/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/64x64/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/72x72/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/96x96/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/128x128/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/192x192/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/256x256/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/384x384/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/512x512/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "/usr/share/icons/hicolor/scalable/apps/io.github.thetumultuousunicornofdarkness.cpu-x.svg" "/usr/ProgramFiles/cpu-x" "/usr/bin/cpu-x"
else
    echo -e "\e[31mE: CPU-X Is Not Installed.\e[0m" >&2
    exit 1
fi
}

appimage_format() {
if ! command -v "/usr/ProgramFiles/cpu-x/bin/cpu-x" &> /dev/null; then
    mkdir -p /usr/ProgramFiles/cpu-x/bin &> /dev/null

    URL=$(curl -s https://api.github.com/repos/TheTumultuousUnicornOfDarkness/CPU-X/releases/latest | grep '"browser_download_url":' | grep '.*\.AppImage' | cut -d '"' -f 4)

    wget -q -O"/usr/ProgramFiles/cpu-x/bin/cpu-x" $URL

    chmod +x "/usr/ProgramFiles/cpu-x/bin/cpu-x"

    ln -s "/usr/ProgramFiles/cpu-x/bin/cpu-x" "/usr/bin/cpu-x"

    $ZZ_BIN x "../../libc/cpu-x.zip" -O"/" -y &> /dev/null

    chmod 644 "/usr/share/applications/cpu-x.desktop"

    update-desktop-database

    VERSION=$(curl -s https://api.github.com/repos/TheTumultuousUnicornOfDarkness/CPU-X/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')
    echo "VERSION=$VERSION" | sudo tee /usr/ProgramFiles/cpu-x/Cpu-X_Version > /dev/null
fi
}

update_appimage() {
    list_file="/usr/ProgramFiles/cpu-x/Cpu-X_Version"

    if [[ ! -f "$list_file" ]]; then
        echo -e "\e[31mE: Unknown Version\e[0m" >&2
        exit 1
    fi

    Cpu_X_APPIMAGE_VERSION=""
    while IFS= read -r line; do
        case "$line" in
            VERSION=*)
                Cpu_X_APPIMAGE_VERSION="${line#VERSION=}"
                ;;
        esac
    done < "$list_file"

    if [[ "$Cpu_X_LATEST_VERSION" == "$Cpu_X_APPIMAGE_VERSION" ]]; then
        echo "You are already using the latest version of CPU-X AppImage: $Cpu_X_APPIMAGE_VERSION"
        exit 0
    fi

    remove_cpu-x_appimage

    appimage_format
}

update_appimage
