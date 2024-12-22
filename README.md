# Parameterized star shaped knobs for hexagonal screws and nuts

Allows to create hand operated star shaped knobs for hexagonal screws and nuts.
The output is widely configurable, see the comments in the `scad` file for details.

## Model on Printables

https://www.printables.com/model/1116311-hex-nut-knobs-parametric-drehknopf-knauf-sechskant

## Details
All knobs are made for ISO 4017 / DIN 933 hex screws and ISO 4032 / DIN 934 hex nuts. The OpenSCAD source can easily be modified to make knobs with US customary units. There are different versions:

1. knob with hub
1. knob without hub
1. securing hub with cutout for a nut. The securing hub can be used as a lock nut for knobs without hub (when using with screws). I use this with super glue between knob and hub to make very stable knobs with screws. Use a second lock nut to tighten the hub, remove the second lock nut after the super glue set.

I have made versions with 5 and 7 arms for the sizes M4, M5, M6, M8. The measures are from the ISO / DIN tables. You can modify them in the OpenSCAD file if they don't fit your needs. It is also possible to modify the number of arms, depth and width of the notches, radius of the edges, size of the hub, and the radius of the knob itself.

The screw heads and nuts should be tight and can be pressed in with a vice. Depending on the horizontal expansion of your printer you might either consider this in your slicer or change the arrays named screws and nuts in the OpenSCAD file accordingly.

Currently I cannot take photos of the knobs I made, will add them later.

## 3D Printing

Depending on your quality and stability requirements you can print with a variety of settings. I usually use this configuration:

Printer: Prusa MK4

Layer height: 0.2mm

Infill: 50% gyroid

Support: only for the rounded knobs with hubs. On the MK4 I print those upside down and sand the top surface with 120, 240, 360 grit. Alternatively, they can also be printed the right way round. On the MK4, the overhang will not look nice despite support, but can also be sanded.