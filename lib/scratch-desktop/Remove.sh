#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m"
    exit 1
fi

if ! command -v scratch-desktop &> /dev/null; then
    echo "Scratch Desktop Is Not Installed, so Cancelling Removed."
    exit 1
else
    echo "Remove Scratch Desktop..."
    if [ -f /etc/debian_version ]; then
        if command -v apt-get &> /dev/null; then
            apt-get autoremove scratch-desktop
        else
            echo -e "\e[31mE: apt-get Is Not Installed.\e[0m"
            exit 1
        fi
    elif [ -f /etc/lsb-release ]; then
        if command -v apt-get &> /dev/null; then
            apt-get autoremove scratch-desktop
        else
            echo -e "\e[31mE: apt-get Is Not Installed.\e[0m"
            exit 1
        fi
    elif [ -f /etc/redhat-release ]; then
        if command -v dnf &> /dev/null; then
            dnf remove scratch-desktop
        else
            echo -e "\e[31mE: dnf Is Not Installed.\e[0m"
        fi
        if command -v yum &> /dev/null; then
            yum remove scratch-desktop
        else
            echo -e "\e[31mE: yum Is Not Installed.\e[0m"
        fi
    fi
    rm -rf "~/.config/Scratch Desktop"
    exit 1
fi
