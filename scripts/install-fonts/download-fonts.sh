#!/bin/bash

VERSION="v3.1.1"
FONTS=("FiraCode" "FiraMono" "Hack" "Inconsolata" "NerdFontsSymbolsOnly" "JetBrainsMono")
DIR="nerd-fonts-tmp"
mkdir -p ./$DIR

git clone https://github.com/pop-os/fonts.git pop-os-fonts/

for FONT in "${FONTS[@]}"; do
  URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/${FONT}.zip"
  wget -P $DIR $URL -q --show-progress
done

