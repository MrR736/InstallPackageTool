#!/bin/bash

GODOT_DIR=

for cmd in rm update-mime-database sed echo; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "\e[31mE: $cmd Is Not Installed.\e[0m"
    exit 1
  fi
done

if ! command -v godot &> /dev/null; then
    echo "Godot is Not Installed, So Cancelling Removal."
    exit 1
else
    echo "Removing Godot..."
fi

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m"
    exit 1
fi

rm -rf "/usr/ProgramFiles/godot/bin/godot" "/usr/share/applications/org.godotengine.Godot.desktop" "/usr/share/icons/hicolor/16x16/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/22x22/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/32x32/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/64x64/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/scalable/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/16x16/places/folder-godot.svg" "/usr/share/icons/hicolor/22x22/places/folder-godot.svg" "/usr/share/icons/hicolor/32x32/places/folder-godot.svg" "/usr/share/icons/hicolor/64x64/places/folder-godot.svg" "/usr/share/icons/hicolor/scalable/places/folder-godot.svg" "/usr/share/mime/packages/org.godotengine.Godot.xml" "/usr/ProgramFiles/godot"

sed -i '/application\/x-godot-shader/d' /usr/share/mime/types &> /dev/null
sed -i '/application\/x-godot-scene/d' /usr/share/mime/types &> /dev/null
sed -i '/application\/x-godot-resource/d' /usr/share/mime/types &> /dev/null
sed -i '/application\/x-godot-project/d' /usr/share/mime/types &> /dev/null
sed -i '/application\/x-gdscript/d' /usr/share/mime/types &> /dev/null

sed -i '/application\/x-godot-shader/d' /usr/share/mime/icons &> /dev/null
sed -i '/application\/x-godot-scene/d' /usr/share/mime/icons &> /dev/null
sed -i '/application\/x-godot-resource/d' /usr/share/mime/icons &> /dev/null
sed -i '/application\/x-godot-project/d' /usr/share/mime/icons &> /dev/null
sed -i '/application\/x-gdscript/d' /usr/share/mime/icons &> /dev/null

sed -i '/application\/x-godot-project text\/plain/d' /usr/share/mime/subclasses &> /dev/null
sed -i '/application\/x-gdscript text\/plain/d' /usr/share/mime/subclasses &> /dev/null
sed -i '/application\/x-godot-shader text\/plain/d' /usr/share/mime/subclasses &> /dev/null

update-mime-database /usr/share/mime

echo "Godot has been Removed successfully."
