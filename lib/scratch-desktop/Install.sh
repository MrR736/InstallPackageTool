#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v scratch-desktop &> /dev/null; then
    echo "Install Scratch Desktop..."
else
    echo "Scratch Desktop is Already Installed, so Cancelling Installation."
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

scratch_desktop_LATEST_VERSION=$(curl -s https://api.github.com/repos/chrismaltby/scratch-desktop/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

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
