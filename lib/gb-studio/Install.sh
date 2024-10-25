#!/bin/bash

gb_studio_BIN="/usr/bin/gb-studio"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m"
    exit 1
fi

if [[ ! -e "$gb_studio_BIN" ]]; then
    echo "Install GB Studio..."
else
    echo "GB Studio is Already Installed, so Cancelling Installation."
    exit 1
fi

for cmd in curl sed mkdir awk wget grep tee cat ln rm; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "\e[31mE: $cmd Is Not Installed.\e[0m"
    exit 1
  fi
done

mkdir -p /usr/ProgramFiles/gb-studio/bin &> /dev/null


download_deb() {
wget -q -O"/tmp/gb-studio.deb" "$URL"
}
download_rpm() {
wget -q -O"/tmp/gb-studio.rpm" "$URL"
}

GB_STUDIO_LATEST_VERSION=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

if [ -f /etc/debian_version ]; then
    URL=https://github.com/chrismaltby/gb-studio/releases/download/$GB_STUDIO_LATEST_VERSION/gb-studio-linux-debian.deb
    download_deb
elif [ -f /etc/lsb-release ]; then
    URL=https://github.com/chrismaltby/gb-studio/releases/download/$GB_STUDIO_LATEST_VERSION/gb-studio-linux-debian.deb
    download_deb
elif [ -f /etc/redhat-release ]; then
    URL=https://github.com/chrismaltby/gb-studio/releases/download/$GB_STUDIO_LATEST_VERSION/gb-studio-linux-redhat.rpm
    download_rpm
else
    echo -e "\e[31mE: Unknown This Linux System.\e[0m"
    exit 1
fi

if [[ -e "/tmp/gb-studio.deb" ]]; then
    if ! command -v apt-get &> /dev/null; then
        echo -e "\e[31mE: apt-get Is Not Installed.\e[0m"
        exit 1
    fi

    if ! command -v dpkg &> /dev/null; then
        echo -e "\e[31mE: dpkg Is Not Installed.\e[0m"
        exit 1
    fi

    {
        dpkg -i /tmp/gb-studio.deb && \
        apt-get install -f && \
        rm -rf "/tmp/gb-studio.deb"
    } || {
        echo -e "\e[31mE: Installation failed.\e[0m"
        rm -f "/tmp/gb-studio.deb"  # Ensure cleanup on failure
        exit 1
    }
elif [[ -e "/tmp/gb-studio.rpm" ]]; then
    if ! command -v rpm &> /dev/null; then
        echo -e "\e[31mE: rpm Is Not Installed.\e[0m"
        exit 1
    fi

    {
        rpm -i /tmp/gb-studio.rpm && \
        rm -rf "/tmp/gb-studio.rpm"
    } || {
        echo -e "\e[31mE: Installation failed.\e[0m"
        rm -f "/tmp/gb-studio.rpm"  # Ensure cleanup on failure
        exit 1
    }
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m"
    exit 1
fi
