#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if ! command -v "/usr/ProgramFiles/godot/bin/godot" &> /dev/null; then
    exit 1
fi

for cmd in chmod curl wget "$ZZ_BIN"; do
    if ! command -v "$cmd" &> /dev/null; then
        if [[ "$ZZ_BIN" != "$cmd" ]]; then
            echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
            exit 1
        else
            echo -e "\e[31mE: 7zz Is Not Installed.\e[0m" >&2
            exit 1
        fi
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

upgrade_godot() {
list_file="/usr/ProgramFiles/godot/Type"

if [[ ! -f "$list_file" ]]; then
    echo -e "\e[31mE: Type file not found: $list_file\e[0m" >&2
    exit 1
fi

godot_type=""
while IFS= read -r line; do
    case "$line" in
        godot_type=*)
            update_godot_type="${line#godot_type=}"
            ;;
    esac
done < "$list_file"

chmod +x ./Remove.sh &> /dev/null
chmod +x ./Install.sh &> /dev/null

if [[ "$update_godot_type" == "godot_stable_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -s > /dev/null
elif [[ "$update_godot_type" == "godot_stable_mono_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -m > /dev/null
fi

}

GODOT_VERSION=$(godot --version | awk -F '.' '{print $1"."$2}')
GODOT_LATEST_VERSION=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

# Compare versions
if [[ "$GODOT_LATEST_VERSION" > "$GODOT_VERSION" ]]; then
    echo "Updating Godot..."
else
    echo "You Are Already Using The Latest Version Of Godot: $GODOT_VERSION"
    exit 1
fi

remove_godot

upgrade_godot
