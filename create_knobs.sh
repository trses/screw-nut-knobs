#!/bin/bash

quality=12

# see if we have a quality argument -q
while getopts q: flag
do
    case "${flag}" in
        q) quality=${OPTARG};;
    esac
done

sizes=("M4" "M5" "M6" "M8")
arms=(5 7)
types=("nut" "nutx")

for size in "${sizes[@]}"; do
    for type in "${types[@]}"; do
        for arm in "${arms[@]}"; do
            /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
             --D TYPE=\"$type\" --D SIZE=\"$size\" --D ARMS=$arm \
             --D QUALITY=$quality \
             --export-format binstl \
             --o ./printables/$size-$type-$arm-arms.stl \
             --backend=manifold screw-nut-knobs.scad
        done
    done

    # hubs don't come with arms
    /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
        --D TYPE=\"hub\" --D SIZE=\"$size\" \
        --D QUALITY=$quality \
        --export-format binstl \
        --o ./printables/$size-hub.stl \
        --backend=manifold screw-nut-knobs.scad
done