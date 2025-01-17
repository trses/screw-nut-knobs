#!/bin/bash

# I use this script to create the different knobs all at once.
# Works with OpenSCAD on Macs. For command line usage on Linux and Windows
# please refer to
# https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment

quality=360

# see if we have a quality argument -q
while getopts q: flag
do
    case "${flag}" in
        q) quality=${OPTARG};;
    esac
done

#sizes=("M4" "M5" "M6" "M8")
sizes=("M4" "M5" "M6" "M8" "M10" "M12" "M14" "M16")
arms=(5 7 51)
# hex, hexnohub, allen, inbus, lockhub
types=("hex" "hexnohub" "allen")
# flat, rounded
shapes=("rounded" "flat")

# create directories
for size in "${sizes[@]}"; do
    for shape in "${shapes[@]}"; do
        mkdir ./printables/new/$size\ $shape\ top
    done
done

mkdir ./printables/new/lock\ hubs

for size in "${sizes[@]}"; do
    for type in "${types[@]}"; do
        for arm in "${arms[@]}"; do
            for shape in "${shapes[@]}"; do
                /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
                --D SIZE=\"$size\" \
                --D TYPE=\"$type\" \
                --D ARMS=$arm \
                --D SHAPE=\"$shape\" \
                --D QUALITY=$quality \
                --export-format binstl \
                --o ./printables/new/$size\ $shape\ top/$size-$type-$arm-arms-$shape.stl \
                --backend=manifold screw-nut-knobs.scad
            done
        done
    done

    # hubs don't come with arms
    /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
         --D SIZE=\"$size\" \
        --D TYPE=\"lockhub\" \
        --D QUALITY=$quality \
        --export-format binstl \
        --o ./printables/new/lock\ hubs/$size-lockhub.stl \
        --backend=manifold screw-nut-knobs.scad
done