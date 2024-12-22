/**
 * Creates handles for hexagon head screws. Various parameters can be
 * controlled:
 * SIZE: M4, M5, M6, M8, the arrays can be extended for further sizes
 * TYPE: knob for nut or screw, with or without hub, securing hub
 * ARMS: number of "arms" of the star shaped knob
 * QUALITY: smoothness of the rendered stl (OpenSCAD $fn value)
 *
 * Note, that further values, e. g. distance and size of the knurls, depth
 * of the recesses (notches), radius of the rounded edge, and the size of the
 * hub can be modified in the source code.
 *
 * Use with caution: Because the rounded edges are generated with the Minkowski
 * operator, the computing time is quite high (in the region of 5 minutes on an
 * AppleSilicon M3 cpu with QUALITY set to 120). For testing, the QUALITY should
 * be set to a very low value such as 12.
 *
 * All dimensions in mm.
 *
 * 3D printing: I usually print them upside down with support and sand the top
 * surface with 120 grit followed by 240 grit
 *
 * Author: Thomas Richter
 * Contact: mail@thomas-richter.info
 */

/*****************************************
 * START PARAMETERS
 * change for 
 * - different sizes
 * - number of arms
 * - rendering quality
 * - type of knob to be rendered
 *****************************************/

// size of the metric screw or nut
SIZE = "M8";

// type to be rendered, possible values:
// - nut: make a knob with hub for a nut
// - nutx: make a knob without hub for a nut
// - screw: make a knob with hub for a screw
// - screwx: make a knob without hub for a screw
// - hub: make a standalone hub with a cutout for a nut. This can be used as a
// lock nut for screwx knobs
//
// The difference between knobs for screws and nuts is the depth of the hexagonal
// cutout: nuts are higher than screw heads (see ISO 4017 and ISO 4032)
// In most cases, handles for nuts are probably required (TYPE = "nut")
TYPE = "nut";

// rounded or flat
SHAPE = "rounded";

// number of arms of the star shaped knob (further down referred to as knurls)
ARMS = 5;

// The higher the better the quality, the higher the computing time
// 120 gives a very smooth finish, computing time around 5 mins with M3 CPU
QUALITY = 12;
/*********** END PARAMETERS ***********/

/*****************************************
 * START CALCULATED VALUES
 * change to get differently shaped knobs
 *****************************************/
// order of parameters, names from DIN / ISO tables in (brackets)
// size, screwDiameter (d1), screwHeadDiameter (e), screwHeadHeight (k)
//
// note that the screwHewadDiameter is the largest dimension, NOT the wrench size.
// In DIN and ISO dimension tables, this dimension is usually designated as e.
//     ___
//    /   \
//    \___/
//    --e--
// dimensions from DIN 933 (ISO 4017)
screws = [
    ["M4", 4,  7.66, 2.8],
    ["M5", 5,  8.79, 3.5],
    ["M6", 6, 11.05, 4.0],
    ["M8", 8, 14.38, 5.3]
];

// order of parameters, names from DIN / ISO tables in (brackets)
// size, threadDiameter, nutDiameter (e), nutHeight (m)
// dimensions from DIN 934 (ISO 4032)
nuts = [
    ["M4", 4,  7.66, 3.2],
    ["M5", 5,  8.79, 4.7],
    ["M6", 6, 11.05, 5.2],
    ["M8", 8, 14.38, 6.8]
];

// calculated values, you might want to change them to get different results
screw = selectScrew(SIZE);
nut = selectNut(SIZE);

knurls = ARMS;

// smoothness of the knob's edges. The hub's radius is half of this size to
// compensate for oversized holes in the part this knob is screwed to
edgeRadius = 2;

// Length of the screw shank that should be inside the knob
// note: the height of the hub is added to this value so that the actual protrusion
// is larger
protrusion = screw[1];

screwDiameter = screw[1];
screwHeadDiameter = screw[2];
screwHeadHeight = screw[3];

nutDiameter = nut[2];
nutHeight = nut[3];

// size of the knob, can alternatively be set to a constant value
knobDiameter = screwDiameter * 6;

// size of the hub
hubHeight = screwDiameter * 1.5;

// the hub has at least a wall thickness at the nut of the thread's radius
hubDiameter = TYPE == "hub" ? nutDiameter + screwDiameter : 2 * screwDiameter;

// perimeter thickness above the screw head if it should be closed
headPerimeter = 0;

// pitch of the knurls: a pitch of one means that one knurl radius ist between two knurls, a pitch of two means that two knurl radii are between two knurls. Since the circumference is constant this setting controls the radius of the knurls: the larger the pitch, the smaller the knurls. Sensible Values are 1, 2, 3
knurlPitch = 2;
// ratio of knurl diameter to notch diameter
// 2 means, notches have twice the radius of knurls.
// The higher the notchRatio is, the flatter the notches are. Sensible values are between 2 and 5
notchRatio = 4;

edgeDiameter = edgeRadius * 2;

// how much the top rounding stands above the top edge
topRoundingHeight = SHAPE == "flat" ? 0 : knobDiameter / 12;

totalHeight = protrusion + screwHeadHeight + headPerimeter;
flatCoreHeight = totalHeight - topRoundingHeight - edgeDiameter;

// knob with lock at the top side
forNut = TYPE == "nut" || TYPE == "nutx";
makeHub = TYPE == "nut" || TYPE == "screw";

// make the thing
if (TYPE == "hub") {
    hub(nut = true);
} else {
    knob(forNut, makeHub);
}

module knob(forNut = false, makeHub = false) {

    difference() {
        knobBody();
        
        // cut off the locks and the screw
        // cut hole for screw shaft
        cylinder(h = totalHeight, d = screwDiameter, $fn = QUALITY);

        // cut hexagonal hole for screw head or nut
        cutHeight = forNut ? nutHeight: screwHeadHeight + headPerimeter;
        cutDiameter = forNut ? nutDiameter : screwHeadDiameter;
        
        translate([0, 0, totalHeight - cutHeight])
            cylinder(h = cutHeight, d = cutDiameter, $fn = 6);
    }
    
    // make a hub
    if (makeHub) {
        // if the hub is part of the knob the hub must not have a cutout for a nut because it cannot be tightened
        rotate([180, 0, 0]) hub(nut = false);
    }
}

module knobBody() {
    angleStep = 360 / knurls;

    // radius of the knob
    rKnob = knobDiameter / 2;
    // radius of the knurls
    rK = PI * rKnob / ((knurlPitch + 1) * knurls + PI);
    // radius of the notches
    rN = notchRatio * rK;
    // radius of the circle to place the knurls
    rPosK = rKnob - rK;

    // angle between knurl and notch
    alpha = angleStep / 2;
    // angle between center of knob, center of notch, center of knurl
    gamma = asin(sin(alpha) * rPosK / (rN + rK));
    // angle between center of knob, center of knurl, center of notch
    beta = 180 - alpha - gamma;
    // radius of the circle to place the notches
    rPosN = rPosK * sin(beta) / sin(gamma);

    // radius of the knob's core: distance from center to touch point of knurl and notch
    rCore = sqrt(rPosK^2 + rK^2 - 2 * rPosK * rK * cos(beta));

    
    difference() {
        translate([0, 0, edgeRadius])
        minkowski(4) {
            sphere(edgeRadius, $fn = QUALITY);
            
            // scale for additional size of minkowski sum
            scaleFactor = (knobDiameter - edgeDiameter) / knobDiameter;

            scale([scaleFactor, scaleFactor, 1])
            difference() {
                union() {
                    // core of the knob
                    cylinder(h = flatCoreHeight + topRoundingHeight, d = rCore * 2, $fn = QUALITY);
                    // place knurls around the core
                    for (i = [0: angleStep: 360 - angleStep]) {
                        rotate([0, 0, i]) {
                            translate([rPosK, 0, 0])
                                cylinder(h = flatCoreHeight + topRoundingHeight, d = rK * 2, $fn = QUALITY);
                        }
                    }
                }

                // subtract a hollow sphere from the knob body
                // radius of the top rounding when viewing from above (parallel to the knob's circumference)
                rTopRoundingArch = knobDiameter / 2 - edgeRadius;
                // distance from the center of the hollow sphere to the knob's surface without the rounding
                distCenterSurface = topRoundingHeight == 0 ?
                    0 :
                    (rTopRoundingArch^2 - topRoundingHeight^2) / (2 * topRoundingHeight);

                translate([0, 0, flatCoreHeight - distCenterSurface])
                    hollowSphere(distCenterSurface + 2.5 * topRoundingHeight, topRoundingHeight + distCenterSurface, $fn = 2 * QUALITY);
        
                // subtract notches around the core
                for (i = [alpha: angleStep: 360]) {
                    rotate([0, 0, i]) {
                        translate([rPosN, 0, 0])
                            cylinder(h = flatCoreHeight + topRoundingHeight, d = rN * 2, $fn = QUALITY);
                    }
                }
            }
        }
    }
}

module hub(nut = false) {
    eR = edgeRadius / 2;
    difference() {
        minkowski() {
            sphere(eR, $fn = QUALITY);

            cylinder(h = hubHeight - eR, d = hubDiameter - 2 * eR, $fn = QUALITY);
        }
        // cut hole for the screw
        cylinder(h = hubHeight + eR * 2, d = screwDiameter, $fn = QUALITY);

        // cut off excessive height from minkowski sum
        translate([0, 0, -eR])
            cylinder(h = eR, d = hubDiameter + eR * 2, $fn = QUALITY);

        if (nut) {
            // cut off hexagonal hole for the securing nut
            translate([0, 0, hubHeight - screwHeadHeight])
                cylinder(h = nutHeight, d = nutDiameter, $fn = 6);
        }
    }
}

module hollowSphere(outerRadius, innerRadius) {
    difference() {
        sphere(outerRadius);
        sphere(innerRadius);
    }
}

// selector function to simplify the selection of the screw
function selectScrew(item, dict = screws) = dict[search([item], dict)[0]];

function selectNut(item) = selectScrew(item, nuts);
