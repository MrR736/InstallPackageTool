#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v "/usr/ProgramFiles/godot/bin/godot" &> /dev/null; then
    echo "Godot Engine is Not Installed, So Cancelling Reinstall." >&2
    exit 1
fi

for cmd in chmod "./Remove.sh" "./Install.sh"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
        exit 1
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

reinstall_godot() {
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

if [ "$(uname -m)" == "x86_64" ]; then
    echo "Reinstall Godot Engine x64 version..." >&2
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    echo "Reinstall Godot Engine x32 version..." >&2
elif [[ "$(uname -m)" == "armv7l" || "$(uname -m)" == "armv6l" || "$(uname -m)" == "armv5tel" ]]; then
    echo "Reinstall Godot Engine Arm32 version..." >&2
elif [ "$(uname -m)" == "aarch64" ]; then
    echo "Reinstall Godot Engine Arm64 version..." >&2
fi

chmod +x ./Remove.sh &> /dev/null
chmod +x ./Install.sh &> /dev/null

if [[ "$update_godot_type" == "godot_stable_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -s > /dev/null
elif [[ "$update_godot_type" == "godot_stable_mono_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -m > /dev/null
fi

echo "Godot has been Reinstall Successfully." >&2
}

reinstall_godot
