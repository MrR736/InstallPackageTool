#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

if ! command -v scratch-desktop &> /dev/null; then
    echo "Scratch Desktop Is Not Installed, so Cancelling Removed."
    exit 1
else
    echo "Remove Scratch Desktop..."
    if command -v apt &> /dev/null; then
        if ! apt autoremove -y scratch-desktop; then
            echo -e "\e[31mE: apt Is Not Installed.\e[0m" >&2
            exit 1
        fi
    elif command -v dnf &> /dev/null; then
        if ! dnf remove -y scratch-desktop; then
            echo -e "\e[31mE: dnf Is Not Installed.\e[0m" >&2
            exit 1
        fi
    elif command -v yum &> /dev/null; then
        if ! yum remove -y scratch-desktop; then
            echo -e "\e[31mE: yum Is Not Installed.\e[0m" >&2
            exit 1
        fi
    elif command -v snap &> /dev/null; then
        if ! sudo snap remove -y scratch-desktop &> /dev/null; then
            echo -e "\e[31mE: snap Is Not Installed.\e[0m" >&2
        fi
    elif command -v nix-shell &> /dev/null; then
        if ! nix-shell -r scratch-desktop &> /dev/null; then
            echo -e "\e[31mE: nix-shell Is Not Installed.\e[0m" >&2
        fi
    fi
    rm -rf "$HOME/.config/Scratch Desktop"
    exit 1
fi

echo "Scratch Desktop has been Removed successfully."
