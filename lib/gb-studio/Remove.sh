#!/bin/bash

gb_studio_BIN="/usr/bin/gb-studio"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

if ! command -v gb-studio &> /dev/null; then
    echo "GB Studio is Not Installed, So Cancelling Removal." >&2
    exit 1
else
    echo "Remove GB Studio..."

    if command -v "/usr/ProgramFiles/gb-studio/bin/gb-studio" &> /dev/null; then
        rm -rf "~/.config/GB Studio" "/usr/share/pixmaps/gb-studio.png" "/usr/share/applications/gb-studio.desktop" "/usr/share/doc/gb-studio" "/usr/share/lintian/overrides/gb-studio" "/usr/bin/gb-studio" "/usr/ProgramFiles/gb-studio"
    else
        if command -v yum &> /dev/null; then
            if ! yum remove -y gb-studio; then
                echo -e "\e[31mE: Failed to remove gb-studio using yum.\e[0m" >&2
                exit 1
            fi
        elif command -v apt &> /dev/null; then
            if ! apt autoremove -y gb-studio; then
                echo -e "\e[31mE: Failed to remove gb-studio using apt.\e[0m" >&2
                exit 1
            fi
        elif command -v dnf &> /dev/null; then
            if ! dnf remove -y gb-studio; then
                echo -e "\e[31mE: Failed to remove gb-studio using dnf.\e[0m" >&2
                exit 1
            fi
        else
            echo -e "\e[31mE: No supported package manager found.\e[0m" >&2
            exit 1
        fi
        rm -rf "~/.config/GB Studio" "/usr/share/pixmaps/gb-studio.png" "/usr/share/applications/gb-studio.desktop" "/usr/share/doc/gb-studio" "/usr/share/lintian/overrides/gb-studio" "/usr/bin/gb-studio" "/usr/ProgramFiles/gb-studio"
    fi
fi

echo "GB Studio has been Removed Successfully." >&2
