#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPTS_DIR

if ! command -v gb-studio &> /dev/null; then
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
wget -q -O"/tmp/gb-studio.deb" "$URL"
}
download_rpm() {
wget -q -O"/tmp/gb-studio.rpm" "$URL"
}

if command -v dpkg &> /dev/null; then
    scratch_desktop_VERSION=$(dpkg -l | grep gb-studio | awk '{print $3}')
    scratch_desktop_VERSION="${scratch_desktop_VERSION%-*}"
elif command -v rpm &> /dev/null; then
    scratch_desktop_VERSION=$(rpm -q --queryformat '%{VERSION}' gb-studio)
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m"
    exit 1
fi

GB_STUDIO_L_V=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')

GB_STUDIO_LATEST_VERSION=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

if [[ $(echo -e "$GB_STUDIO_L_V\n$gb_studio_VERSION" | sort -V | head -n1) != "$gb_studio_VERSION" ]]; then
    echo "Updating GB Studio..."
else
    echo "You are already using the latest version of GB Studio: $gb_studio_VERSION"
    exit 1
fi

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
    echo "Unsupported distribution"
    exit 1
fi

cat <<EOL | sudo tee "../gb_studio.list" > /dev/null
VERSION=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')
EOL

if [[ -e "/tmp/scratch-desktop.deb" ]]; then
    if ! command -v apt-get &> /dev/null; then
        echo -e "\e[31mE: apt-get Is Not Installed.\e[0m"
        exit 1
    fi

    if ! command -v dpkg &> /dev/null; then
        echo -e "\e[31mE: dpkg Is Not Installed.\e[0m"
        exit 1
    fi

    dpkg -i /tmp/gb-studio.deb
    apt-get install -f
    rm -rf "/tmp/gb-studio.deb"
elif [[ -e "/tmp/scratch-desktop.rpm" ]]; then
    if ! command -v rpm &> /dev/null; then
        echo -e "\e[31mE: rpm Is Not Installed.\e[0m"
        exit 1
    fi

    rpm -i /tmp/gb-studio.rpm
    rm -rf "/tmp/gb-studio.rpm"
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m"
    exit 1
fi
