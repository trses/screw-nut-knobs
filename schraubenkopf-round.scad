/**
 * Creates handles for hexagon head screws. Various parameters can be
 * controlled:
 * Number of knurls, distance and size of the knurls, depth of the recesses
 * (notches), radius of the rounded edge and, of course, the dimensions of
 * the screw.
 *
 * The screw is fixed with an insert (lock). There are two variants:
 * * Lock on the top - allows printing without support
 *     set the parameter topLock to true (default)
 * * Lock on the bottom side - cannot come loose when the screw is screwed in,
 * but requires printing with support if the handle is to have a rounded edge.
 *     set the parameter topLock to false
 * The locks go through the whole knob such that they can be removed easily
 * unless they are glued in place. If you don't like the look just shorten the
 * fixating cylinders in the lock module.
 *
 * Use with caution: Because the rounded edges are generated with the Minkowski
 * operator, the computing time is quite high (in the region of 5 minutes on an
 * AppleSilicon M3 cpu with EDGE_QUALITY set to 36). For testing, the edge
 * radius should be set to 0. Alternatively, the EDGE_QUALITY can be set to a
 * very low value such as 6.
 *
 * All dimensions in mm.
 *
 * Author: Thomas Richter
 * Contact: mail@thomas-richter.info
 */


/*****************************************
 * START PARAMETERS
 * change for 
 * - different sizes
 * - number of arms (knurls)
 * - rendering quality
 * - radius of edges
 * - hub sizes
 *****************************************/
 
// order of parameters, names from DIN / ISO tables in (brackets)
// Name, screwDiameter (d1), screwHeadDiameter (e), screwHeadHeight (k)
//
// screwHewadDiameter: largest dimension, NOT the wrench size.
// In DIN and ISO dimension tables, this dimension is usually
// designated as e.
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

TYPE = "M6";

screw = selectScrew(TYPE);

// number of knurls (arms) around the circumference
knurls = 5;

// The higher the better the quality, the higher the computing time
// 120 gives a very smooth finish, computing time around 5 mins with M3 CPU
EDGE_QUALITY = 12;

echo("quality", EDGE_QUALITY);

edgeRadius = 2;

// size of the hub, set to 0 for no hub
hubDiameter = 0;

hubHeight = 0;

/*********** END PARAMETERS ***********/


/*****************************************
 * START CALCULATED VALUES
 * change to get differently shaped knobs
 *****************************************/

// calculated values, you might want to change them to get different results
screwDiameter = screw[1];
screwHeadDiameter = screw[2];
screwHeadHeight = screw[3];

// size of the knob, can alternatively be set to a constant value
//knobDiameter = screwDiameter * 8;
knobDiameter = screwDiameter * 6;

// Length of the screw shank that should be inside the knob,
// can alternatively be set to a constant value
//protrusion = screwDiameter - 1;
protrusion = 8;

// perimeter thickness above the screw head
headPerimeter = 0;

// pitch of the knurls: a pitch of one means that one knurl radius ist between two knurls, a pitch of two means that two knurl radii are between two knurls. Since the circumference is constant this setting controls the radius of the knurls: the larger the pitch, the smaller the knurls. Sensible Values are 1, 2, 3
knurlPitch = 2;
// ratio of knurl diameter to notch diameter
// 2 means, notches have twice the radius of knurls.
// The higher the notchRatio is, the flatter the notches are. Sensible values are between 2 and 5
notchRatio = 4;

edgeDiameter = edgeRadius * 2;

// how much the top rounding stands above the top edge
topRoundingHeight = knobDiameter / 12;
//topRoundingHeight = 0;

totalHeight = protrusion + screwHeadHeight + headPerimeter;
flatCoreHeight = totalHeight - topRoundingHeight - edgeDiameter;

// knob with lock at the top side
knob();

module knob(topLock = true) {

    difference() {
        knobBody();
        
        // cut off the locks and the screw
        // cut hole for screw shaft
        cylinder(h = totalHeight, d = screwDiameter, $fn = EDGE_QUALITY);

        // cut hexagonal hole for screw head
        translate([0, 0, totalHeight - screwHeadHeight]) { cylinder(h = screwHeadHeight + headPerimeter, d = screwHeadDiameter, $fn = 6); }

//      cube(25);
        
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
            sphere(edgeRadius, $fn = EDGE_QUALITY);
            
            // scale for additional size of minkowski sum
            scaleFactor = (knobDiameter - edgeDiameter) / knobDiameter;
            scale([scaleFactor, scaleFactor, 1])
            difference() {
                union() {
                    // core of the knob
                    cylinder(h = flatCoreHeight + topRoundingHeight, d = rCore * 2, $fn = EDGE_QUALITY);
                    // place knurls around the core
                    for (i = [0: angleStep: 360 - angleStep]) {
                        rotate([0, 0, i]) {
                            translate([rPosK, 0, 0])
                            cylinder(h = flatCoreHeight + topRoundingHeight, d = rK * 2, $fn = EDGE_QUALITY);
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
                hollowSphere(distCenterSurface + 2.5 * topRoundingHeight, topRoundingHeight + distCenterSurface, $fn = 2 * EDGE_QUALITY);
        
                // subtract notches around the core
                for (i = [alpha: angleStep: 360]) {
                    rotate([0, 0, i]) {
                        translate([rPosN, 0, 0])
                        cylinder(h = flatCoreHeight + topRoundingHeight, d = rN * 2, $fn = EDGE_QUALITY);
                    }
                }
            }
        }
    }
}

module sphericalSector(radius, angle) {
    rotate_extrude() {
        difference() {
            circle(radius);
            
            polygon([
                [0, 0],
                [radius, radius * sin(90 - angle) / cos(90 - angle)],
                [radius, -radius],
                [-radius, -radius],
                [-radius, radius],
                [0, radius]
            ]);
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
