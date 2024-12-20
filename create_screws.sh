#!/bin/bash

sizes=("M4" "M5") # "M6" "M8")
arms=(5 7)
types=("nut" "nutx" "screw" "screwx")

for size in "${sizes[@]}"; do
    for type in "${types[@]}"; do
        for arm in "${arms[@]}"; do
            /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
             --D TYPE=\"$type\" --D SIZE=\"$size\" --D ARMS=$arm \
             --D QUALITY=12 \
             --export-format binstl \
             --o ./printables/$size-$type-$arm-arms.stl \
             --backend=manifold schraubenkopf-round.scad
        done
    done

    # hubs don't come with arms
    /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
        --D TYPE=\"hub\" --D SIZE=\"$size\" \
        --D QUALITY=12 \
        --export-format binstl \
        --o ./printables/$size-hub.stl \
        --backend=manifold schraubenkopf-round.scad
done