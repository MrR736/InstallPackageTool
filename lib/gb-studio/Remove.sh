#!/bin/bash

gb_studio_BIN="/usr/bin/gb-studio"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m"
    exit 1
fi

if [[ ! -e "$gb_studio_BIN" ]]; then
    echo "GB Studio is Already Installed, so Cancelling Installation."
    exit 1
else
    echo "Remove GB Studio..."
    if [ -f /etc/debian_version ]; then
        if command -v apt-get &> /dev/null; then
            apt-get autoremove gb-studio
        else
            echo -e "\e[31mE: apt Is Not Installed.\e[0m"
            exit 1
        fi
    elif [ -f /etc/lsb-release ]; then
        if command -v apt-get &> /dev/null; then
            apt-get autoremove gb-studio
        else
            echo -e "\e[31mE: apt Is Not Installed.\e[0m"
            exit 1
        fi
    elif [ -f /etc/redhat-release ]; then
        if command -v dnf &> /dev/null; then
            dnf remove gb-studio
        else
            echo -e "\e[31mE: dnf Is Not Installed.\e[0m"
            exit 1
        fi
        if command -v yum &> /dev/null; then
            yum remove gb-studio
        else
            echo -e "\e[31mE: yum Is Not Installed.\e[0m"
            exit 1
        fi
    fi
    rm -rf "~/.config/GB Studio"
    exit 1
fi
