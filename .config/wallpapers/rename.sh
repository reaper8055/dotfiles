#!/usr/bin/env bash

i=1
for f in *; do
    if [[ "$f" == "rename.sh" ]]; then
        continue
    fi
    ext="${f##*.}"
    mv "$f" "wallpaper-${i}.$ext"
    ((i++))
done

