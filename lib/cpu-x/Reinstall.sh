#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

if ! command -v "/usr/ProgramFiles/cpu-x/bin/cpu-x" &> /dev/null; then
    echo "CPU-X is Not Installed, So Cancelling Reinstall." >&2
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

reinstall_cpu_x() {
echo "Reinstall CPU-X x64 version..." >&2

./Remove.sh > /dev/null
./Install.sh -a > /dev/null

echo "CPU-X has been Reinstall Successfully." >&2
}

reinstall_cpu_x
