#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

for cmd in curl sed mkdir awk wget grep tee cat ln rm "$ZZ_BIN"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
        exit 1
    fi
done

if ! command -v "gb-studio" &> /dev/null && ! command -v "/usr/ProgramFiles/gb-studio/bin/gb-studio" &> /dev/null; then
    echo "Install GB Studio..."
else
    echo "GB Studio is Already Installed, so Cancelling Installation." >&2
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

package_format() {
if command -v dpkg &> /dev/null && ! command -v gb-studio &> /dev/null; then
    URL=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep '"browser_download_url":' | grep '.*\.deb' | cut -d '"' -f 4)
    wget -q -O"/tmp/gb-studio.deb" "$URL"
elif command -v rpm &> /dev/null && ! command -v gb-studio &> /dev/null; then
    URL=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep '"browser_download_url":' | grep '.*\.rpm' | cut -d '"' -f 4)
    wget -q -O"/tmp/gb-studio.rpm" "$URL"
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
    exit 1
fi

if [[ -e "/tmp/gb-studio.deb" ]]; then
    if ! command -v apt-get &> /dev/null; then
        echo -e "\e[31mE: apt-get Is Not Installed.\e[0m" >&2
        exit 1
    fi

    if ! command -v dpkg &> /dev/null; then
        echo -e "\e[31mE: dpkg Is Not Installed.\e[0m" >&2
        exit 1
    fi

    {
        dpkg -i /tmp/gb-studio.deb && \
        apt-get install -f && \
        rm -rf "/tmp/gb-studio.deb"
    } || {
        echo -e "\e[31mE: Installation failed.\e[0m" >&2
        rm -f "/tmp/gb-studio.deb"  # Ensure cleanup on failure
        exit 1
    }
elif [[ -e "/tmp/gb-studio.rpm" ]]; then
    if ! command -v rpm &> /dev/null; then
        echo -e "\e[31mE: rpm Is Not Installed.\e[0m" >&2
        exit 1
    fi

    {
        rpm -i /tmp/gb-studio.rpm && \
        rm -rf "/tmp/gb-studio.rpm"
    } || {
        echo -e "\e[31mE: Installation failed.\e[0m" >&2
        rm -f "/tmp/gb-studio.rpm"  # Ensure cleanup on failure
        exit 1
    }
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
    exit 1
fi

echo "GB Studio has been Install Successfully."
}

appimage_format() {

mkdir -p /usr/ProgramFiles/gb-studio/bin &> /dev/null

URL=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep '"browser_download_url":' | grep '.*\.AppImage' | cut -d '"' -f 4)

wget -q -O"/usr/ProgramFiles/gb-studio/bin/gb-studio" $URL

chmod +x "/usr/ProgramFiles/gb-studio/bin/gb-studio"

ln -s "/usr/ProgramFiles/gb-studio/bin/gb-studio" "/usr/bin/gb-studio"

$ZZ_BIN x "../../libc/gb-studio.zip" -O"/" -y &> /dev/null

chmod 644 "/usr/share/applications/gb-studio.desktop"

update-desktop-database

VERSION=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')
echo "VERSION=$VERSION" | sudo tee "/usr/ProgramFiles/gb-studio/Version" > /dev/null

echo "GB Studio has been Install Successfully."
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
