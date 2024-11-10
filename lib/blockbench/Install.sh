#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

if ! command -v blockbench &> /dev/null && ! command -v "/opt/Blockbench/blockbench" &> /dev/null && ! command -v "/usr/ProgramFiles/blockbench/bin/blockbench" &> /dev/null; then
    echo "Install Blockbench..."
else
    echo "Blockbench is Already Installed, so Cancelling Installation."
    exit 1
fi

for cmd in cd wget curl tee grep awk sed rm cut "$ZZ_BIN"; do
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

error_upm() {
echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
rm -rf "/tmp/blockbench.deb" "/tmp/blockbench.rpm"
}

download_deb() {
URL=$(curl -s https://api.github.com/repos/JannisX11/blockbench/releases/latest | grep '"browser_download_url":' | grep '.*\.deb' | cut -d '"' -f 4)
wget -q -O"/tmp/blockbench.deb" "$URL"

if [[ -e "/tmp/blockbench.deb" ]] && command -v apt-get &> /dev/null && command -v dpkg &> /dev/null; then
    dpkg -i /tmp/blockbench.deb
    apt-get install -f
    rm -rf "/tmp/blockbench.deb"
else
    error_upm
    exit 1
if
}

download_rpm() {
URL=$(curl -s https://api.github.com/repos/JannisX11/blockbench/releases/latest | grep '"browser_download_url":' | grep '.*\.rpm' | cut -d '"' -f 4)
wget -q -O"/tmp/blockbench.rpm" "$URL"

if [[ -e "/tmp/blockbench.rpm" ]] && command -v rpm &> /dev/null; then
    rpm -i /tmp/blockbench.rpm
    rm -rf "/tmp/blockbench.rpm"
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

chmod 644 "/usr/share/applications/blockbench.desktop"

update-desktop-database

VERSION=$(curl -s https://api.github.com/repos/JannisX11/blockbench/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')
echo "VERSION=$VERSION" | sudo tee "/usr/ProgramFiles/blockbench/Version" > /dev/null
}

appimage_format() {
if [ "$(uname -m)" == "x86_64" ]; then
    if ! command -v "/usr/ProgramFiles/blockbench/bin/blockbench" &> /dev/null; then
        download_appimage
    fi
else
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi
}

package_format() {
if [ "$(uname -m)" == "x86_64" ]; then
    if command -v dpkg &> /dev/null && command -v apt-get &> /dev/null; then
        download_deb
    elif command -v rpm &> /dev/null; then
        download_rpm
    fi
else
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi
}

type_of_install() {
read -p "What Type Of Install Format, Do You Want? [Package=p/AppImage=a/No=n]" InstallFormat

if [[ "$InstallFormat" == "p" ]]; then
    package_format
elif [[ "$InstallFormat" == "a" ]]; then
    appimage_format
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [[ "$1" == "-p" ]]; then
    package_format
    exit 1
elif [[ "$1" == "-a" ]]; then
    appimage_format
    exit 1
fi

type_of_install
