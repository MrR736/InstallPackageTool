#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPTS_DIR
ZZ_BIN="../../bin/7zz"

if ! command -v scratch-desktop &> /dev/null; then
    exit 1
fi

for cmd in curl sed grep; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
    exit 1
  fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

if command -v dpkg &> /dev/null; then
    scratch_desktop_VERSION=$(dpkg -l | grep scratch-desktop | awk '{print $3}')
    scratch_desktop_VERSION="${scratch_desktop_VERSION%-*}"
elif command -v rpm &> /dev/null; then
    scratch_desktop_VERSION=$(rpm -q --queryformat '%{VERSION}' scratch-desktop)
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
    exit 1
fi

scratch_desktop_LATEST_VERSION=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

if [[ $(echo -e "$scratch_desktop_LATEST_VERSION\n$scratch_desktop_VERSION" | sort -V | head -n1) != "$scratch_desktop_VERSION" ]]; then
    echo "Updating Scratch Desktop..."
else
    echo "You are already using the latest version of Scratch Desktop: $scratch_desktop_VERSION"
    exit 1
fi

if command -v apt &> /dev/null; then
    if ! sudo apt upgrade -y scratch-desktop &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade Scratch Desktop using apt.\e[0m" >&2
    fi
elif command -v dnf &> /dev/null; then
    if ! sudo dnf upgrade -y scratch-desktop &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade Scratch Desktop using dnf.\e[0m" >&2
    fi
elif command -v yum &> /dev/null; then
    if ! sudo yum upgrade -y scratch-desktop &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade Scratch Desktop using yum.\e[0m" >&2
    fi
elif command -v snap &> /dev/null; then
    if ! sudo snap refresh scratch-desktop &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade Scratch Desktop using snap.\e[0m" >&2
    fi
elif command -v nix-shell &> /dev/null; then
    if ! nix-shell -u scratch-desktop &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade Scratch Desktop using nix-shell.\e[0m" >&2
    fi
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m"
fi
