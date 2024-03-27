#!/usr/bin/env bash

for zipFile in ./fonts/src/*.zip; do
  unzip $zipFile -d ./pop-os-fonts-tmp/
done

sudo cp -R ./pop-os-fonts /usr/share/fonts/
cp -R ./pop-os-fonts-tmp $HOME/.local/share/fonts/

for zipFile in ./nerd-fonts-tmp/*.zip; do
  baseName=$(basename -- "$zipFile")
  # extension="${filename##*.}"
  fontDirName="${baseName%.*}"
  if [ -d "/usr/share/fonts/$fontDirName" ]; then
    sudo rm -rf /usr/share/fonts/$fontDirName
  else
    sudo mkdir -p /usr/share/fonts/$fontDirName
    sudo unzip $zipFile -d /usr/share/fonts/$fontDirName
  fi

  if [ -d "$HOME/.local/share/fonts/$fontDirName" ]; then
   rm -rf $HOME/.local/share/fonts/$fontDirName
  else
   mkdir -p $HOME/.local/share/fonts/$fontDirName
   unzip $zipFile -d $HOME/.local/share/fonts/$fontDirName
  fi
done

fc-cache -fv
sudo fc-cache -fv
