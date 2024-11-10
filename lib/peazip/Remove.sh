#!/bin/bash

for cmd in rm echo; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
        exit 1
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

remove_peazip_package() {
if command -v apt &> /dev/null; then
    if ! sudo apt remove -y peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Remove PeaZip using apt.\e[0m" >&2
    fi
elif command -v dnf &> /dev/null; then
    if ! sudo dnf remove -y peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Remove PeaZip using dnf.\e[0m" >&2
    fi
elif command -v yum &> /dev/null; then
    if ! sudo yum remove peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Remove PeaZip using yum.\e[0m" >&2
    fi
elif command -v snap &> /dev/null; then
    if ! sudo snap remove -y peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Remove PeaZip using snap.\e[0m" >&2
    fi
elif command -v nix-shell &> /dev/null; then
    if ! nix-shell -r peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Remove PeaZip using nix-shell.\e[0m" >&2
    fi
elif command -v flatpak &> /dev/null; then
    if ! flatpak remove flathub org.peazip.PeaZip &> /dev/null; then
        echo -e "\e[31mE: Failed To Remove PeaZip using flatpak.\e[0m" >&2
    fi
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m"
fi
}

if ! command -v peazip &> /dev/null; then
    echo "PeaZip is Not Installed, So Cancelling Removal."
    exit 1
else
    echo "Removing PeaZip..."
fi

if ! command -v "/usr/ProgramFiles/peazip/bin/peazip" &> /dev/null; then
    remove_peazip_package
fi

rm -rf "/usr/share/applications/peazip.desktop" "/usr/share/doc/peazip" "/usr/share/pixmaps/peazip_add.png" "/usr/share/pixmaps/peazip_extract.png" "/usr/share/pixmaps/peazip.png" "/usr/share/peazip" "/usr/ProgramFiles/peazip" "/usr/bin/peazip" "/usr/bin/pea"

echo "PeaZip has been Removed Successfully."
