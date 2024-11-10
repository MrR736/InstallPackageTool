#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v scratch-desktop &> /dev/null; then
    echo "Install Scratch Desktop..."
else
    echo "Scratch Desktop is Already Installed, so Cancelling Installation."
    exit 1
fi

for cmd in curl sed mkdir awk wget grep tee cat ln rm; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
        exit 1
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

portable_format() {
if command -v dpkg &> /dev/null && ! command -v scratch-desktop &> /dev/null; then
    if [ "$(uname -m)" == "x86_64" ]; then
        URL=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep '"browser_download_url":' | grep '.*\amd64.deb' | cut -d '"' -f 4)
    elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
        URL=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep '"browser_download_url":' | grep '.*\i386.deb' | cut -d '"' -f 4)
    else
        echo -e "\e[31mE: Unknown Type of Arch\e[0m" >&2
        exit 1
    fi

    if ! command -v apt-get &> /dev/null; then
        echo -e "\e[31mE: apt-get Is Not Installed.\e[0m" >&2
        rm -rf "/tmp/scratch-desktop.deb"
        exit 1
    fi

    if ! command -v dpkg &> /dev/null; then
        echo -e "\e[31mE: dpkg Is Not Installed.\e[0m" >&2
        rm -rf "/tmp/scratch-desktop.deb"
        exit 1
    fi

    wget -q -O"/tmp/scratch-desktop.deb" $URL

    dpkg -i /tmp/scratch-desktop.deb
    apt-get install -f
    rm -rf "/tmp/scratch-desktop.deb"
elif command -v rpm &> /dev/null && ! command -v scratch-desktop &> /dev/null; then
    URL=$(curl -s https://api.github.com/repos/redshaderobotics/scratch3.0-linux/releases/latest | grep '"browser_download_url":' | grep '.*\x86_64.rpm' | cut -d '"' -f 4)
    wget -q -O"/tmp/scratch-desktop.rpm" $URL

    if ! command -v rpm &> /dev/null; then
        echo -e "\e[31mE: rpm Is Not Installed.\e[0m" >&2
        rm -rf "/tmp/scratch-desktop.rpm"
        exit 1
    fi

    rpm -i /tmp/scratch-desktop.rpm
    rm -rf "/tmp/scratch-desktop.rpm"
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
    exit 1
fi
}

type_of_install() {
read -p "What Type Of Install Format, Do You Want? [Package=p/No=n]" InstallFormat

if [[ "$InstallFormat" == "p" ]]; then
    package_format
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [[ "$1" == "-p" ]]; then
    package_format
    exit 1
fi

type_of_install
