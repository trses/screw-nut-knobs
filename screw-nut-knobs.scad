/**
 * Creates handles for hexagon head screws, Allen screws and hexagonal nuts.
 * Various parameters can be controlled:
 * SIZE: M4, M5, M6, M8, the arrays can be extended for further sizes
 * TYPE: knob for nut or screw, with or without hub, allen screw with securing hub
 * SHAPE: flat or rounded top
 * ARMS: number of "arms" of the star shaped knob
 * QUALITY: smoothness of the rendered stl (OpenSCAD $fn value)
 *
 * Note, that further values, e. g. distance and size of the arms, depth
 * of the recesses (notches), radius of the rounded edge, and the size of the
 * hub can be modified in the source code.
 *
 * Use with caution: Because the rounded edges are generated with the Minkowski
 * operator, the computing time for the rounded-top version is quite high (in the
 * region of 7 minutes on an AppleSilicon M3 cpu with QUALITY set to 120). For
 * testing, the QUALITY should be set to a very low value such as 12.
 *
 * All dimensions in mm.
 *
 * 3D printing: I usually print the rounded-top version upside down with support
 * and sand the top surface with 120, 240, and 360 grit
 *
 * License: CC BY-NC-SA 4.0
 *          Creative Commons 4.0 Attribution — Noncommercial — Share Alike
 *          https://creativecommons.org/licenses/by-nc-sa/4.0/
 *
 * Author: Thomas Richter
 * Contact: mail@thomas-richter.info
 */

/*****************************************
 * START PARAMETERS
 * change for 
 * - different sizes
 * - type of knob to be rendered (for nut or screw)
 * - shape of knob (rounded or flat top)
 * - number of arms
 * - rendering quality
 *****************************************/

/* [Parameters:] */
// size of the metric screw or nut or free: if you select "free" customize the detailed values in the Dimensions Tab
SIZE = "M8"; // [M4, M5, M6, M8, free]

// TYPE possible values:
// - nut: make a knob with hub for a nut
// - nutx: make a knob without hub for a nut
// - allen: make a knob with hub for an Allen screw with lock nut in the hub
// - screw: make a knob with hub for a screw
// - screwx: make a knob without hub for a screw
// - hub: make a standalone hub with a cutout for a nut. This can be used as a
// lock nut for screwx knobs
//
// The difference between knobs for screws and nuts is the depth of the hexagonal
// cutout: nuts are higher than screw heads (see ISO 4017 and ISO 4032)
// In most cases, handles for nuts are probably suitable (TYPE = "nut"), even for screws
// type of knob to be rendered
TYPE = "allen"; // [nut, allen, screw, hub, nutx, screwx]

// Caution: the rounded top makes a difference of several minutes in rendering time
// M8 flat top: 11 seconds, M8 rounded top: 7 minutes on Apple M3 CPU
// shape of the top surface (rounded is very slow, up to several minutes)
SHAPE = "flat"; // [flat: flat, rounded: rounded - very slow]

// number of arms
ARMS = 5;

// Diameter of the knob in relation to the screw diameter
DIAMETER_RATIO = 7; // [5 : 10]

// 120 gives a very smooth finish, computing time around 7 mins for knobs with rounded top on an M3 CPU
// The higher the better the quality, the higher the computing time
QUALITY = 36; // [18 : 120]

// The values in the Dimensions tab have only to be customized if you choose the SIZE value "free"
/* [Dimensions:] */
THREAD_DIAMETER = 8.0; // .01

// Attention! This NOT the wrench size but the diameter of the head measured across the corners
HEX_SCREW_HEAD_DIAMETER_ACROSS_CORNERS = 14.38; // .01

HEX_SCREW_HEAD_HEIGHT = 5.3; // .01

ALLEN_HEAD_DIAMETER = 13.0; // .01

ALLEN_HEAD_HEIGHT = 8.0; // .01

// Attention! This NOT the wrench size but the diameter of the nut measured across the corners
HEX_NUT_DIAMETER_ACROSS_CORNERS = 14.38; // .01

HEX_NUT_HEIGHT = 6.8; // .01

/*********** END PARAMETERS ***********/

/*****************************************
 * START CALCULATED VALUES
 * change to get differently shaped knobs
 *****************************************/

 /* [Hidden] */
 
 /**
 * Measures of metric screws and nuts accoring to
 * ISO 4017 / DIN 933 - hexagonal head screws
 * ISO 4032 / DIN 934 - hexagonal nuts
 * ISO 4762 / DIN 921 - Allen screws
 *
 * License: CC BY-NC-SA 4.0
 *          Creative Commons 4.0 Attribution — Noncommercial — Share Alike
 *          https://creativecommons.org/licenses/by-nc-sa/4.0/
 *
 * Author: Thomas Richter
 * Contact: mail@thomas-richter.info
 */

// order of parameters, names from DIN / ISO tables in (brackets)
// size, screwDiameter (d1), screwHeadDiameter (e), screwHeadHeight (k), allenHeadDiameter (dk), allenHeadHeight (k)
//
// note that the screwHewadDiameter is the largest dimension, NOT the wrench size.
// In DIN and ISO dimension tables, this dimension is usually designated as e.
//     ___
//    /   \
//    \___/
//    --e--
// dimensions from DIN 933 / ISO 4017 and DIN 912 / ISO 4762 (inbus / allen)
// [size, d1, e, k, inbus dk, inbus k]
screws = [
    ["M4", 4,  7.66, 2.8,  7.0, 4],
    ["M5", 5,  8.79, 3.5,  8.5, 5],
    ["M6", 6, 11.05, 4.0, 10.0, 6],
    ["M8", 8, 14.38, 5.3, 13.0, 8],
    // US dimensions according to ASME B18.2.1, ASME B18.2.2 
    // name, thread size, head diameter across corners (e), head height (h), allen head diameter, allen head height]
    // ["5/32"]
    // ["3/16"]
    // ["1/4",  1/4, 0.505, 5/32, 3/8, 1/4]
    // ["5/16", 5/16, 0.577, 7/32]
];

// order of parameters, names from DIN / ISO tables in (brackets)
// size, threadDiameter, nutDiameter (e), nutHeight (m)
// dimensions from DIN 934 / ISO 4032
nuts = [
    ["M4", 4,  7.66, 3.2],
    ["M5", 5,  8.79, 4.7],
    ["M6", 6, 11.05, 5.2],
    ["M8", 8, 14.38, 6.8],
];

// get the measures from measures.scad or from the Customizer view
screw = SIZE != "free"
    ? selectScrew(SIZE)
    : [
        "free",
        THREAD_DIAMETER,
        HEX_SCREW_HEAD_DIAMETER_ACROSS_CORNERS,
        HEX_SCREW_HEAD_HEIGHT,
        ALLEN_HEAD_DIAMETER,
        ALLEN_HEAD_HEIGHT
    ];

nut = SIZE != "free"
    ? selectNut(SIZE)
    : [
        "free",
        THREAD_DIAMETER,
        HEX_NUT_DIAMETER_ACROSS_CORNERS,
        HEX_NUT_HEIGHT,
    ];

// smoothness of the knob's edges. The hub's radius is half of this size to
// compensate for oversized holes in the part this knob is screwed to
edgeRadius = 2;

// Length of the screw shank that should be inside the knob
// note: the height of the hub is added to this value so that the actual protrusion
// is larger
protrusion = screw[1];

screwDiameter = screw[1];
screwHeadDiameter = TYPE == "allen" ? screw[4] : screw[2];
screwHeadHeight = TYPE == "allen" ? screw[5] : screw[3];

nutDiameter = nut[2];
nutHeight = nut[3];

// size of the knob, can alternatively be set to a constant value
knobDiameter = screwDiameter * DIAMETER_RATIO;

// size of the hub
hubHeight = screwDiameter * 1.5;

// the hub has at least a wall thickness at the nut of the thread's radius
hubDiameter = TYPE == "allen" || TYPE == "hub"
    ? nutDiameter + screwDiameter
    : 2 * screwDiameter;

// pitch of the arms: a pitch of one means that one arm radius ist between two arms, a pitch of two means that two arm radii are between two arms. Since the circumference is constant this setting controls the radius of the arms: the larger the pitch, the smaller the arms. Sensible Values are 1, 2, 3
armPitch = 2;

// ratio of arm diameter to notch diameter
// 2 means, notches have twice the radius of arms.
// The higher the notchRatio is, the flatter the notches are. Sensible values are between 2 and 5
//notchRatio = 4;
notchRatio = 4;

edgeDiameter = edgeRadius * 2;

// how much the top rounding stands above the top edge
topRoundingHeight = SHAPE == "flat" ? 0 : knobDiameter / 12;

totalHeight = protrusion + screwHeadHeight;
flatCoreHeight = totalHeight - topRoundingHeight - edgeDiameter;

// configure the knob
forNut = TYPE == "nut" || TYPE == "nutx";
makeHub = TYPE == "nut" || TYPE == "screw" || TYPE == "allen";

// make the thing
if (TYPE == "hub") {
    hub(nut = true, slot = true);
} else {
    translate([0, 0, 0]) knob(forNut, makeHub);
}

module knob(forNut = false, makeHub = false) {

    difference() {
        knobBody();
        
        // cut off the locks and the screw
        // cut hole for screw shaft
        cylinder(h = totalHeight, d = screwDiameter, $fn = QUALITY);

        // cut hexagonal hole for screw head or nut
        cutHeight = forNut ? nutHeight : screwHeadHeight;
        cutDiameter = forNut ? nutDiameter : screwHeadDiameter;
        // for allen screws make a circular cutout
        // for  hex screws and nuts make a hexagonal cutout
        edges = TYPE == "allen" ? QUALITY : 6;
        
        translate([0, 0, totalHeight - cutHeight])
            cylinder(h = cutHeight, d = cutDiameter, $fn = edges);
    }
    
    // make a hub
    if (makeHub) {
        // if the knob is for allen screws the hub has a cutout for the lock nut
        rotate([180, 0, 0]) hub(nut = TYPE == "allen");
    }
}

module knobBody() {
    angleStep = 360 / ARMS;

    // radius of the knob
    rKnob = knobDiameter / 2;
    // radius of the arms
    rK = PI * rKnob / ((armPitch + 1) * ARMS + PI);
    // radius of the notches
    rN = notchRatio * rK;
    // radius of the circle to place the arms
    rPosK = rKnob - rK;

    // angle between arm and notch
    alpha = angleStep / 2;
    // angle between center of knob, center of notch, center of arm
    gamma = asin(sin(alpha) * rPosK / (rN + rK));
    // angle between center of knob, center of arm, center of notch
    beta = 180 - alpha - gamma;
    // radius of the circle to place the notches
    rPosN = rPosK * sin(beta) / sin(gamma);

    // radius of the knob's core: distance from center to touch point of arm and notch
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
                    // place arms around the core
                    for (i = [0: angleStep: 360 - angleStep]) {
                        rotate([0, 0, i]) {
                            translate([rPosK, 0, 0])
                                cylinder(h = flatCoreHeight + topRoundingHeight, d = rK * 2, $fn = QUALITY);
                        }
                    }
                }

                if (topRoundingHeight != 0) {
                    // subtract a hollow sphere from the knob body
                    // radius of the top rounding when viewing from above (parallel to the knob's circumference)
                    rTopRoundingArch = knobDiameter / 2 - edgeRadius;
                    // distance from the center of the hollow sphere to the knob's surface without the rounding
                    distCenterSurface = (rTopRoundingArch^2 - topRoundingHeight^2) / (2 * topRoundingHeight);

                    translate([0, 0, flatCoreHeight - distCenterSurface])
                        hollowSphere(distCenterSurface + 2.5 * topRoundingHeight, topRoundingHeight + distCenterSurface, $fn = 2 * QUALITY);
                }
        
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

module hub(nut = false, slot = false) {
    eR = edgeRadius / 2;
    difference() {
        minkowski() {
            sphere(eR, $fn = QUALITY);

            // -eR: compensate for the enlargement by the minkowski sum
            cylinder(h = hubHeight - eR, d = hubDiameter - 2 * eR, $fn = QUALITY);
        }
        // cut hole for the screw
        cylinder(h = hubHeight + eR * 2, d = screwDiameter, $fn = QUALITY);

        // cut off excessive height from minkowski sum
        translate([0, 0, -eR])
            cylinder(h = eR, d = hubDiameter + eR * 2, $fn = QUALITY);

        if (nut) {
            nutPosZ = slot ? 0 : hubHeight - nutHeight - 1;
        
            // cut off hexagonal hole for the securing nut
            // -1 / +1: additional depth for printing tolerances
            translate([0, 0, nutPosZ])
                cylinder(h = nutHeight + 1, d = nutDiameter, $fn = 6);
            
            // cut of slot to insert the nut sideways
            if (slot) {
                translate([nutDiameter / 2, 0, 0])
                    // use a second cylinder to avoid calculating the width of the slot
                    cylinder(h = nutHeight + 1, d = nutDiameter, $fn = 6);
            }
        }
    }
}

module hollowSphere(outerRadius, innerRadius) {
    difference() {
        sphere(outerRadius);
        sphere(innerRadius);
    }
}

// selector functions to simplify the selection of the entities
function selectFromDict(item, dict) = dict[search([item], dict)[0]];

function selectScrew(size) = selectFromDict(size, screws);

function selectNut(size) = selectFromDict(size, nuts);