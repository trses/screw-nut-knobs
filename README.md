# Parameterized star shaped knobs for hexagonal and Allen screws and nuts

Allows to create hand operated star shaped knobs for hexagonal and Allen screws and nuts.
The output is widely configurable, see the comments in the `.scad` file for details.

## Updates
The numbers refer to issues in the GitHub Repository.

### 2024-12-22
* fixes #5: nut in securing hub too low, replaced the `.stl` files
* feature #3: added support for Allen screws

## Model on Printables

https://www.printables.com/model/1116311-parametric-knob-for-hex-nuts-and-allen-screws-knau

## Details
All knobs are made for ISO 4017 / DIN 933 hex screws, ISO 4762 / DIN 912 Allen screws and ISO 4032 / DIN 934 hex nuts. Other sizes as well as knobs for US customary screws and nuts can be achieved by customizing (see section Customization below). There are different versions that can be created:

1. knob with hub
1. knob without hub
1. knob for Allen screw with securing hub
1. securing hub with cutout for a nut. The securing hub can be used as a lock nut for knobs without hub (when using with hexagonal head screws). I use this with super glue between knob and hub to make very stable knobs with screws. Use a second lock nut to tighten the hub, remove the second lock nut after the super glue set.

I have made versions with 5 and 7 arms for the sizes M4, M5, M6, M8. The measures are from the ISO / DIN tables. You can modify them in the OpenSCAD file if they don't fit your needs. It is also possible to modify the number of arms, depth and width of the notches, radius of the edges, size of the hub, and the radius of the knob itself.

If someone provides me with the ASME B18.2.1, B18.2.2, and B18.3 tables I can create US versions and upload them to Printables.

The screw heads and nuts should be tight and can be pressed in with a vice. In the version with Allen screw, the lock nut can be pulled into the spacer by tightening the screw with the Allen key. Depending on the horizontal expansion of your printer you might either consider this in your slicer or change the arrays named `screws` and `nuts` in the OpenSCAD file accordingly. On the MK4 I don't compensate for horizontal expansion and get a nice tight fit.

## Customization
You can use the Customizer view in OpenSCAD (Window -> Customizer) to create your own knobs. You can also modify further variables in the source code to fit your needs.

If you want to create other sizes or knobs for US customary (imperial) screws and nuts, select "free" as SIZE in the OpenSCAD Customizer view (tab "Parameters") and set the dimensions in the tab "Dimensions" according to your needs. Remember to set the values in Millimeters (inch * 25.4).

If you create your own knobs with the OpenSCAD files make sure to use the manifold backend for rendering (Options -> Extended -> 3D Rendering -> Backend -> Manifold). If your version of OpenSCAD doesn't have this option, download the [latest development snapshot](https://openscad.org/downloads.html#snapshots). Otherwise the rendering with CGAL will literally take hours, especially for the knobs with rounded top.

## 3D Printing

Depending on your quality and stability requirements you can print with a variety of settings. I usually use this configuration:

Printer: Prusa MK4

Layer height: 0.2mm

Perimeter: 2mm everywhere

Infill: 50% gyroid

Support: only for the rounded knobs with hubs and for the Allen screw knobs. On the MK4 I print those upside down and sand the top surface with 120, 240, 360 grit. Alternatively, they can also be printed the right way round. On the MK4, the overhang will not look nice despite support, but can also be sanded.