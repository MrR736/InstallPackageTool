#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPTS_DIR
ZZ_BIN="../../bin/7zz"

if ! command -v scratch-desktop &> /dev/null; then
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

download_deb() {
wget -q -O"/tmp/scratch-desktop.deb" "$URL"
}
download_rpm() {
wget -q -O"/tmp/scratch-desktop.rpm" "$URL"
}

if command -v dpkg &> /dev/null; then
    scratch_desktop_VERSION=$(dpkg -l | grep scratch-desktop | awk '{print $3}')
    scratch_desktop_VERSION="${scratch_desktop_VERSION%-*}"
elif command -v rpm &> /dev/null; then
    scratch_desktop_VERSION=$(rpm -q --queryformat '%{VERSION}' scratch-desktop)
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m"
    exit 1
fi

scratch_desktop_LATEST_VERSION=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

if [[ $(echo -e "$scratch_desktop_LATEST_VERSION\n$scratch_desktop_VERSION" | sort -V | head -n1) != "$scratch_desktop_VERSION" ]]; then
    echo "Updating Scratch Desktop..."
else
    echo "You are already using the latest version of Scratch Desktop: $scratch_desktop_VERSION"
    exit 1
fi

if [ -f /etc/debian_version ]; then
    if [ "$(uname -m)" == "x86_64" ]; then
        URL=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep '"browser_download_url":' | grep '.*amd64\.deb' | cut -d '"' -f 4)
    fi
    if [ "$(uname -m)" == "i686" ]; then
        URL=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep '"browser_download_url":' | grep '.*i386\.deb' | cut -d '"' -f 4)
    fi
    download_deb
elif [ -f /etc/lsb-release ]; then
    if [ "$(uname -m)" == "x86_64" ]; then
        URL=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep '"browser_download_url":' | grep '.*amd64\.deb' | cut -d '"' -f 4)
    fi
    if [ "$(uname -m)" == "i686" ]; then
        URL=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep '"browser_download_url":' | grep '.*i386\.deb' | cut -d '"' -f 4)
    fi
    download_deb
elif [ -f /etc/redhat-release ]; then
    URL=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep '"browser_download_url":' | grep '.*x86_64\.rpm' | cut -d '"' -f 4)
    download_rpm
else
    echo "Unsupported distribution"
    exit 1
fi

if [[ -e "/tmp/scratch-desktop.deb" ]]; then
    if ! command -v apt-get &> /dev/null; then
        echo -e "\e[31mE: apt-get Is Not Installed.\e[0m"
        rm -rf "/tmp/scratch-desktop.deb"
        exit 1
    fi

    if ! command -v dpkg &> /dev/null; then
        echo -e "\e[31mE: dpkg Is Not Installed.\e[0m"
        rm -rf "/tmp/scratch-desktop.deb"
        exit 1
    fi

    dpkg -i /tmp/scratch-desktop.deb
    apt-get install -f
    rm -rf "/tmp/scratch-desktop.deb"
elif [[ -e "/tmp/scratch-desktop.rpm" ]]; then
    if ! command -v rpm &> /dev/null; then
        echo -e "\e[31mE: rpm Is Not Installed.\e[0m"
        rm -rf "/tmp/scratch-desktop.rpm"
        exit 1
    fi

    rpm -i /tmp/scratch-desktop.rpm
    rm -rf "/tmp/scratch-desktop.rpm"
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m"
    rm -rf "/tmp/scratch-desktop.deb" "/tmp/scratch-desktop.rpm"
    exit 1
fi
