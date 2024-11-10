#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"
Tar_BIN="../../bin/tar"

for cmd in curl wget awk sed grep ln rm update-mime-database echo mkdir "$ZZ_BIN" "$Tar_BIN"; do
    if ! command -v "$cmd" &> /dev/null; then
        if [[ "$ZZ_BIN" == "$cmd" ]]; then
            echo -e "\e[31mE: 7zz Is Not Installed.\e[0m" >&2
            exit 1
        elif [[ "$Tar_BIN" == "$cmd" ]]; then
            echo -e "\e[31mE: tar Is Not Installed.\e[0m" >&2
            exit 1
        else
            echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
            exit 1
        fi
    fi
done

if command -v "/usr/lib/ventoy/VentoyGUI.x86_64" &> /dev/null; then
    echo "Ventoy is Already Installed, so Cancelling Installation."
    exit 1
elif command -v "/usr/lib/ventoy/VentoyGUI.i386" &> /dev/null; then
    echo "Ventoy is Already Installed, so Cancelling Installation."
    exit 1
elif command -v "/usr/lib/ventoy/VentoyGUI.aarch64" &> /dev/null; then
    echo "Ventoy is Already Installed, so Cancelling Installation."
    exit 1
elif command -v "/usr/lib/ventoy/VentoyGUI.mips64el" &> /dev/null; then
    echo "Ventoy is Already Installed, so Cancelling Installation."
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

ventoy_format() {
echo "Install Ventoy..."

URL=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep '"browser_download_url":' | grep '.*\.tar.gz' | grep "linux" | cut -d '"' -f 4)

mkdir -p "/usr/share/doc/ventoy" "/usr/lib/ventoy" "/tmp/ventoy" &> /dev/null

wget -q -O"/tmp/ventoy.tar.gz" $URL

wget -q -O"/usr/share/doc/ventoy/copyright" https://github.com/ventoy/Ventoy/raw/refs/heads/master/COPYING

wget -q -O"/usr/share/doc/ventoy/BuildVentoyFromSource" https://github.com/ventoy/Ventoy/raw/refs/heads/master/DOC/BuildVentoyFromSource.txt

wget -q -O"/usr/share/doc/ventoy/LoopExBuild" https://github.com/ventoy/Ventoy/raw/refs/heads/master/DOC/LoopExBuild.txt

wget -q -O"/usr/share/doc/ventoy/README" https://github.com/ventoy/Ventoy/raw/refs/heads/master/INSTALL/README

$Tar_BIN -xzf "/tmp/ventoy.tar.gz" -C "/tmp/ventoy" &> /dev/null

cp -r /tmp/ventoy/*/* /usr/lib/ventoy

$ZZ_BIN x "../../libc/ventoy.zip" -O"/" -y &> /dev/null

sed -i '2s|.*|cd /usr/lib/ventoy|' /usr/lib/ventoy/CreatePersistentImg.sh

sed -i '2s|.*|cd /usr/lib/ventoy|' /usr/lib/ventoy/ExtendPersistentImg.sh

sed -i '2s|.*|cd /usr/lib/ventoy|' /usr/lib/ventoy/VentoyPlugson.sh

sed -i '2s|.*|cd /usr/lib/ventoy|' /usr/lib/ventoy/VentoyWeb.sh

sed -i '2s|.*|cd /usr/lib/ventoy|' /usr/lib/ventoy/VentoyVlnk.sh

sed -i '2s|.*|cd /usr/lib/ventoy|' /usr/lib/ventoy/Ventoy2Disk.sh

sed -i '44s|.*|mkdir -p \~/.local/share/Ventoy|' /usr/lib/ventoy/Ventoy2Disk.sh

sed -i '45s|.*|echo "############# Ventoy2Disk \$* [\$TOOLDIR] ################" \>\> \~/.local/share/Ventoy/log.txt|' /usr/lib/ventoy/Ventoy2Disk.sh

sed -i '46s|.*|date \>\> \~/.local/share/Ventoy/log.txt|' /usr/lib/ventoy/Ventoy2Disk.sh

sed -i '49s|.*|echo "decompress tools" \>\> \~/.local/share/Ventoy/log.txt|' /usr/lib/ventoy/Ventoy2Disk.sh

sed -i '57s|.*|        echo "decompress \$file" \>\> \~/.local/share/Ventoy/log.txt|' /usr/lib/ventoy/Ventoy2Disk.sh

sed -i '60s|.*|        [ -f ./\$file ] \&\& rm -rf ./\$file|' /usr/lib/ventoy/Ventoy2Disk.sh

sed -i '51s|.*|mkdir -p \~/.local/share/Ventoy|' /usr/lib/ventoy/VentoyPlugson.sh

sed -i '52s|.*|echo "############# VentoyPlugson \$* [\$TOOLDIR] ################" \>\> \~/.local/share/Ventoy/VentoyPlugson.log|' /usr/lib/ventoy/VentoyPlugson.sh

sed -i '53s|.*|echo "decompress tools" \>\> \~/.local/share/Ventoy/VentoyPlugson.log|' /usr/lib/ventoy/VentoyPlugson.sh

sed -i '57s|.*|        echo "decompress \$file" \>\> \~/.local/share/Ventoy/VentoyPlugson.log|' /usr/lib/ventoy/VentoyPlugson.sh

sed -i '66s|.*|        [ -f ./\$file ] \&\& rm -rf ./\$file|' /usr/lib/ventoy/VentoyPlugson.sh

rm -rf "/tmp/ventoy.tar.gz" "/tmp/ventoy" "/usr/bin/cpi" "/usr/bin/epi" "/usr/bin/vp" "/usr/bin/vw" "/usr/bin/vv" "/usr/bin/v2d" "/usr/lib/ventoy/README" "/usr/bin/ventoy" "/usr/bin/ventoyedit"

if [ "$(uname -m)" == "x86_64" ]; then
    sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.x86_64|' /usr/share/applications/ventoy.desktop
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.i386|' /usr/share/applications/ventoy.desktop
elif [ "$(uname -m)" == "aarch64" ]; then
    sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.aarch64|' /usr/share/applications/ventoy.desktop
elif [ "$(uname -m)" == "mips64el" ]; then
    sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.mips64el|' /usr/share/applications/ventoy.desktop
else
    echo -e "\e[31mE: Unknown Type of Arch: $(uname -m)\e[0m" >&2
    exit 1
fi

cat > "/usr/lib/ventoy/ventoyedit" << EOF
#!/bin/bash

Help_VentoyEdit() {
echo "Usage: VentoyEdit [OPTION]..."
echo
echo "  -e machine, --execute-type=\$(uname -m)"
echo
echo "  -f, --reset-desktop"
echo
echo "  -s, --stable-execute"
echo
echo "  -t machine, --edit-desktop-execute=\$(uname -m)"
echo
echo "Github home page: <https://github.com/MrR736>"
}

VentoyEdit() {


if [ "\$1" == "-t" ]; then

    if [ "\$(whoami)" != "root" ]; then
        echo -e "\\e[31mE: You have to run as Superuser\\e[0m" >&2
        exit 1
    fi

    if [ "\$2" == "x86_64" ]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.x86_64|' /usr/share/applications/ventoy.desktop
    elif [[ "\$2" =~ ^i[3-6]86\$ ]]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.i386|' /usr/share/applications/ventoy.desktop
    elif [ "\$2" == "aarch64" ]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.aarch64|' /usr/share/applications/ventoy.desktop
    elif [ "\$2" == "mips64el" ]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.mips64el|' /usr/share/applications/ventoy.desktop
    else
        echo -e "\\e[31mE: Unknown Type of Machine: \$2\\e[0m" >&2
        exit 1
    fi
elif [[ "\$1" =~ ^--edit-desktop-execute=(.*) ]]; then
    Command_T="\${BASH_REMATCH[1]}"

    if [ "\$(whoami)" != "root" ]; then
        echo -e "\\e[31mE: You have to run as Superuser\\e[0m" >&2
        exit 1
    fi

    if [ "\$Command_T" == "x86_64" ]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.x86_64|' /usr/share/applications/ventoy.desktop
    elif [[ "\$Command_T" =~ ^i[3-6]86\$ ]]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.i386|' /usr/share/applications/ventoy.desktop
    elif [ "\$Command_T" == "aarch64" ]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.aarch64|' /usr/share/applications/ventoy.desktop
    elif [ "\$Command_T" == "mips64el" ]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.mips64el|' /usr/share/applications/ventoy.desktop
    else
        echo -e "\\e[31mE: Unknown Type of Machine: \$Command_T\\e[0m" >&2
        exit 1
    fi
elif [[ "\$1" =~ ^--execute-type=(.*) ]]; then
    Command_E="\${BASH_REMATCH[1]}"

    if [ "\$(whoami)" != "root" ]; then
        echo -e "\\e[31mE: You have to run as Superuser\\e[0m" >&2
        exit 1
    fi

    if [ "\$Command_E" == "x86_64" ]; then
        exec /usr/lib/ventoy/VentoyGUI.x86_64
    elif [[ "\$Command_E" =~ ^i[3-6]86\$ ]]; then
        exec /usr/lib/ventoy/VentoyGUI.i386
    elif [ "\$Command_E" == "aarch64" ]; then
        exec /usr/lib/ventoy/VentoyGUI.aarch64
    elif [ "\$Command_E" == "mips64el" ]; then
        exec /usr/lib/ventoy/VentoyGUI.mips64el
    else
        echo -e "\\e[31mE: Unknown Type of Machine: \$Command_E\\e[0m" >&2
        exit 1
    fi
elif [ "\$1" == "-e" ]; then

    if [ "\$(whoami)" != "root" ]; then
        echo -e "\\e[31mE: You have to run as Superuser\\e[0m" >&2
        exit 1
    fi

    if [ "\$2" == "x86_64" ]; then
        exec /usr/lib/ventoy/VentoyGUI.x86_64
    elif [[ "\$2" =~ ^i[3-6]86\$ ]]; then
        exec /usr/lib/ventoy/VentoyGUI.i386
    elif [ "\$2" == "aarch64" ]; then
        exec /usr/lib/ventoy/VentoyGUI.aarch64
    elif [ "\$2" == "mips64el" ]; then
        exec /usr/lib/ventoy/VentoyGUI.mips64el
    else
        echo -e "\\e[31mE: Unknown Type of Machine: \$2\\e[0m" >&2
        exit 1
    fi
elif [ "\$1" == "-f" ] || [ "\$1" == "--reset-desktop" ]; then

    if [ "\$(whoami)" != "root" ]; then
        echo -e "\\e[31mE: You have to run as Superuser\\e[0m" >&2
        exit 1
    fi

    if [ "\$(uname -m)" == "x86_64" ]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.x86_64|' /usr/share/applications/ventoy.desktop
    elif [[ "\$(uname -m)" =~ ^i[3-6]86\$ ]]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.i386|' /usr/share/applications/ventoy.desktop
    elif [ "\$(uname -m)" == "aarch64" ]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.aarch64|' /usr/share/applications/ventoy.desktop
    elif [ "\$(uname -m)" == "mips64el" ]; then
        sed -i '161s|.*|Exec=/usr/lib/ventoy/VentoyGUI.mips64el|' /usr/share/applications/ventoy.desktop
    else
        echo -e "\\e[31mE: Unknown Type of Machine: \$(uname -m)\\e[0m" >&2
        exit 1
    fi
elif [ "\$1" == "-s" ] || [ "\$1" == "--stable-execute" ]; then

    if [ "\$(whoami)" != "root" ]; then
        echo -e "\\e[31mE: You have to run as Superuser\\e[0m" >&2
        exit 1
    fi

    if [ "\$(uname -m)" == "x86_64" ]; then
        exec /usr/lib/ventoy/VentoyGUI.x86_64
    elif [[ "\$(uname -m)" =~ ^i[3-6]86\$ ]]; then
        exec /usr/lib/ventoy/VentoyGUI.i386
    elif [ "\$(uname -m)" == "aarch64" ]; then
        exec /usr/lib/ventoy/VentoyGUI.aarch64
    elif [ "\$(uname -m)" == "mips64el" ]; then
        exec /usr/lib/ventoy/VentoyGUI.mips64el
    else
        echo -e "\\e[31mE: Unknown Type of Machine: \$(uname -m)\\e[0m" >&2
        exit 1
    fi
elif [ "\$1" == "" ]; then
    Help_VentoyEdit
else
    echo -e "\\e[31mE: Unknown Type of Option: \$1\\e[0m" >&2
fi
}

VentoyEdit \$1 \$2
EOF

chmod +x "/usr/lib/ventoy/ventoyedit"

ln -s "/usr/lib/ventoy/ventoyedit" "/usr/bin/ventoyedit"

ln -s "/usr/lib/ventoy/CreatePersistentImg.sh" "/usr/bin/cpi"

ln -s "/usr/lib/ventoy/ExtendPersistentImg.sh" "/usr/bin/epi"

ln -s "/usr/lib/ventoy/VentoyPlugson.sh" "/usr/bin/vp"

ln -s "/usr/lib/ventoy/VentoyWeb.sh" "/usr/bin/vw"

ln -s "/usr/lib/ventoy/VentoyVlnk.sh" "/usr/bin/vv"

ln -s "/usr/lib/ventoy/Ventoy2Disk.sh" "/usr/bin/v2d"

ln -s "/usr/lib/ventoy/ventoy/version" "/usr/lib/ventoy/version"

chmod 644 "/usr/share/applications/ventoy.desktop"

update-desktop-database

echo "Ventoy has been Install successfully."
}

type_of_install() {
read -p "What Type Of Install Format, Do You Want? [Ventoy=v/No=n]" InstallFormat

if [[ "$InstallFormat" == "v" ]]; then
    ventoy_format
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [[ "$1" == "-v" ]]; then
    ventoy_format
    exit 1
fi

type_of_install
