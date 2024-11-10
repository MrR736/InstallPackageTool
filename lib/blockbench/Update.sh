#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

if ! command -v blockbench &> /dev/null; then
    exit 1
fi

for cmd in curl sed mkdir awk wget grep tee cat ln rm; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "\e[31mE: $cmd Is Not Installed.\e[0m"
    exit 1
  fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m"
    exit 1
fi

remove_blockbench_appimage() {
if command -v "/usr/ProgramFiles/blockbench/bin/blockbench" &> /dev/null; then
    rm -rf "~/.config/Blockbench" "/usr/share/applications/blockbench.desktop" "/usr/share/doc/blockbench" "/usr/share/icons/hicolor/16x16/apps/blockbench.png" "/usr/share/icons/hicolor/32x32/apps/blockbench.png" "/usr/share/icons/hicolor/48x48/apps/blockbench.png" "/usr/share/icons/hicolor/64x64/apps/blockbench.png" "/usr/share/icons/hicolor/128x128/apps/blockbench.png" "/usr/share/icons/hicolor/256x256/apps/blockbench.png" "/usr/share/icons/hicolor/512x512/apps/blockbench.png" "/usr/share/mime/packages/blockbench.xml" "/usr/bin/blockbench" "/usr/ProgramFiles/blockbench"
else
    echo -e "\e[31mE: Blockbench Is Not Installed.\e[0m"
    exit 1
fi
}

error_upm() {
echo -e "\e[31mE: No Supported Package Manager Found.\e[0m"
rm -rf "/tmp/blockbench.deb" "/tmp/blockbench.rpm"
}

upgrade_blockbench() {
if command -v apt-get &> /dev/null; then
    apt-get upgrade blockbench
elif command -v dnf &> /dev/null; then
    dnf remove blockbench
elif command -v yum &> /dev/null; then
    yum upgrade blockbench
elif command -v snap &> /dev/null; then
    snap refresh blockbench
elif command -v flatpak &> /dev/null; then
    flatpak update flathub net.blockbench.Blockbench
else
    error_upm
    exit 1
fi
}

download_appimage() {
mkdir -p /usr/ProgramFiles/blockbench/bin &> /dev/null
URL=$(curl -s https://api.github.com/repos/JannisX11/blockbench/releases/latest | grep '"browser_download_url":' | grep '.*\.AppImage' | cut -d '"' -f 4)

wget -q -O"/usr/ProgramFiles/blockbench/bin/blockbench" $URL

chmod +x "/usr/ProgramFiles/blockbench/bin/blockbench"

ln -s "/usr/ProgramFiles/blockbench/bin/blockbench" "/usr/bin/blockbench"

$ZZ_BIN x "../../libc/Blockbench.zip" -O"/" -y &> /dev/null

update-desktop-database

VERSION=$(curl -s https://api.github.com/repos/JannisX11/blockbench/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')
echo "VERSION=$VERSION" | sudo tee "/usr/ProgramFiles/blockbench/Version" > /dev/null
}

update_appimage() {
    list_file="/usr/ProgramFiles/blockbench/Version"

    if [[ ! -f "$list_file" ]]; then
        echo -e "\e[31mE: List file not found: $list_file\e[0m"
        exit 1
    fi

    BLOCKBENCH_APPIMAGE_VERSION=""
    while IFS= read -r line; do
        case "$line" in
            VERSION=*)
                BLOCKBENCH_APPIMAGE_VERSION="${line#VERSION=}"
                ;;
        esac
    done < "$list_file"

    if [[ "$blockbench_LATEST_VERSION" == "$BLOCKBENCH_APPIMAGE_VERSION" ]]; then
        echo "You are already using the latest version of Blockbench AppImage: $BLOCKBENCH_APPIMAGE_VERSION"
        exit 0
    fi

    remove_blockbench_appimage

    download_appimage
}

update_blockbench() {
if command -v dpkg &> /dev/null; then
    blockbench_VERSION=$(dpkg -l | grep blockbench | awk '{print $3}')
    blockbench_VERSION="${blockbench_VERSION%-*}"
elif command -v rpm &> /dev/null; then
    blockbench_VERSION=$(rpm -q --queryformat '%{VERSION}' blockbench)
else
    error_upm
    exit 1
fi

blockbench_LATEST_VERSION=$(curl -s https://api.github.com/repos/JannisX11/blockbench/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')

if [[ ! "$blockbench_LATEST_VERSION" > "$blockbench_VERSION" ]]; then
    echo "You are already using the latest version of Blockbench: $blockbench_VERSION"
    exit 1
fi

if command -v "/usr/ProgramFiles/blockbench/bin/blockbench" &> /dev/null; then
    update_appimage
else
    upgrade_blockbench
fi
exit 1
}

update_blockbench
