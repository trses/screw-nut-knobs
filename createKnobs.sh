#!/bin/bash

# I use this script to create the different knobs all at once.
# Works with OpenSCAD on Macs. For command line usage on Linux and Windows
# please refer to
# https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment

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
# nut, nutx, screw, screwx, allen, hub
types=("allen")
# flat, rounded
shape="rounded"

for size in "${sizes[@]}"; do
    for type in "${types[@]}"; do
        for arm in "${arms[@]}"; do
            /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
             --D TYPE=\"$type\" --D SIZE=\"$size\" --D ARMS=$arm \
             --D SHAPE=\"$shape\" \
             --D QUALITY=$quality \
             --export-format binstl \
             --o ./printables/$size-$type-$arm-arms.stl \
             --backend=manifold screw-nut-knobs.scad
        done
    done

#    # hubs don't come with arms
#    /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
#        --D TYPE=\"hub\" --D SIZE=\"$size\" \
#        --D QUALITY=$quality \
#        --export-format binstl \
#        --o ./printables/$size-hub.stl \
#        --backend=manifold screw-nut-knobs.scad
done