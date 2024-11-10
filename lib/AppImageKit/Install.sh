#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if command -v "/usr/ProgramFiles/appimagekit/AppRun" &> /dev/null; then
    echo "Godot is Already Installed, so Cancelling Installation." >&2
    exit 1
fi

for cmd in chmod curl sed mkdir awk wget grep tee cat ln rm "$ZZ_BIN"; do
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

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

appimagetool_format() {
if [ "$(uname -m)" == "x86_64" ]; then
    echo "Install AppImage Tools x64 version..."
    URL=$(curl -s https://api.github.com/repos/AppImage/AppImageKit/releases/latest | grep '"browser_download_url":' | grep '.*\x86_64.AppImage' | cut -d '"' -f 4 | grep -v '\.zsync')
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    echo "Install AppImage Tools x32 version..."
    URL=$(curl -s https://api.github.com/repos/AppImage/AppImageKit/releases/latest | grep '"browser_download_url":' | grep '.*\i686.AppImage' | cut -d '"' -f 4 | grep -v '\.zsync')
elif [[ "$(uname -m)" == "armv7l" || "$(uname -m)" == "armv6l" || "$(uname -m)" == "armv5tel" ]]; then
    echo "Install AppImage Tools Arm32 version..."
    URL=$(curl -s https://api.github.com/repos/AppImage/AppImageKit/releases/latest | grep '"browser_download_url":' | grep '.*\armhf.AppImage' | cut -d '"' -f 4 | grep -v '\.zsync')
elif [ "$(uname -m)" == "aarch64" ]; then
    echo "Install AppImage Tools Arm64 version..."
    URL=$(curl -s https://api.github.com/repos/AppImage/AppImageKit/releases/latest | grep '"browser_download_url":' | grep '.*\aarch64.AppImage' | cut -d '"' -f 4 | grep -v '\.zsync')
else
    echo -e "\e[31mE: Unknown Type of Arch\e[0m" >&2
    exit 1
fi

VERSION=$(echo $P_URL | cut -d/ -f8)

mkdir -p "/usr/ProgramFiles/appimagekit/lib" &> /dev/null

wget -q -O"/usr/ProgramFiles/appimagekit/appimagetool" $URL

$ZZ_BIN x "/usr/ProgramFiles/appimagekit/appimagetool" -O"/usr/ProgramFiles/appimagekit" -y &> /dev/null

ln -s "/usr/ProgramFiles/appimagekit/AppRun" "/usr/bin/appimagetool"

echo "VERSION=$VERSION" | sudo tee -a /usr/ProgramFiles/appimagekit/Data > /dev/null
}

type_of_install() {
read -p "What Type Of Install Format, Do You Want? [AppImageTools=a/No=n]" InstallFormat

if [[ "$InstallFormat" == "a" ]]; then
    appimagetool_format
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [[ "$1" == "-a" ]]; then
    appimagetool_format
    exit 1
fi

type_of_install
