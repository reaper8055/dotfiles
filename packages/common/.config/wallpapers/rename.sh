#!/usr/bin/env bash

i=1
for f in *; do
    if [[ "$f" == "rename.sh" ]] || [[ "${f%.*}" =~ ^wallpaper-[0-9]+$ ]]; then
        continue
    fi
    ext="${f##*.}"
    mv "$f" "wallpaper-${i}.$ext"
    ((i++))
done

