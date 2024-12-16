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

// Diameter of the screw head, largest dimension, NOT the wrench size.
// In DIN and ISO dimension tables, this dimension is usually designated as e.
//     ___
//    /   \
//    \___/
//    --e--
/**/
// M6 screw
screwHeadDiameter = 11.3;
// In DIN and ISO dimension tables, this dimension is usually designated as k.
screwHeadHeight = 4.2;
// Size of the screw (M4, M5, ...). In DIN and ISO dimension tables, this dimension is usually designated as d1.
screwDiameter = 6;
/*
// M5 screw
screwHeadDiameter = 9.2;
screwHeadHeight = 3.5;
screwDiameter = 5;
/*
// M4 screw
screwHeadDiameter = 8.1;
screwHeadHeight = 2.8;
screwDiameter = 4;
/**/

// size of the knob, can alternatively be set to a constant value
knobDiameter = screwDiameter * 8;

// Length of the screw shank that should be inside the knob,
// can alternatively be set to a constant value
protrusion = screwDiameter - 1;

// perimeter thickness above the screw head
headPerimeter = 2;

knobHeight = headPerimeter + screwHeadHeight + protrusion;

// number of knurls around the circumference
knurls = 8;
// pitch of the knurls: a pitch of one means that one knurl radius ist between two knurls, a pitch of two means that two knurl radii are between two knurls. Since the circumference is constant this setting controls the radius of the knurls: the larger the pitch, the smaller the knurls. Sensible Values are 1, 2, 3
knurlPitch = 2;
// ratio of knurl diameter to notch diameter
// 2 means, notches have twice the radius of knurls.
// The higher the notchRatio is, the flatter the notches are. Sensible values are between 2 and 5
notchRatio = 4;

// The higher the better the quality, the higher the computing time
EDGE_QUALITY = 120;

edgeRadius = 2;

// Uncomment one of the following lines to generate the respective parts

// knob with lock at the top side
knob(edgeRadius, topLock = true);

// knob with lock at the bottom side
//knob(edgeRadius = 2, topLock = false);

// the locks
//lock();
//lock(false);

module knob(edgeRadius = 0, topLock = true) {
    edgeDiameter = edgeRadius * 2;
    scaleFactor = (knobDiameter - edgeDiameter) / knobDiameter;

    rotate([180, 0, 0])
    difference() {
        translate([0, 0, edgeRadius]) {
            minkowski(10) {
                sphere(edgeRadius, $fn = EDGE_QUALITY);

                scale([scaleFactor, scaleFactor, 1]) knobBody();
            }
        }

        // cut off excessive height from minkowski operator
        translate([0, 0, knobHeight]) {
            cylinder(h = edgeDiameter, d = knobDiameter + 1);
        }

        // cut off the locks and the screw
        if (topLock) {
            // cut hole for screw shaft
            cylinder(h = knobHeight, d = screwDiameter, $fn = EDGE_QUALITY);

            // cut hexagonal hole for screw head
            translate([0, 0, headPerimeter]) { cylinder(h = screwHeadHeight, d = screwHeadDiameter, $fn = 6); }

            // cut off lock
            lock();
        } else {
            // cut off screw head
            translate([0, 0, headPerimeter]) { cylinder(h = knobHeight, d = screwHeadDiameter, $fn = 6); }

            // cut off lock
            translate([0, 0, knobHeight]) rotate([180, 0, 0]) lock(false);
        }
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
        union() {
            cylinder(h = knobHeight, d = rCore * 2, $fn = EDGE_QUALITY);
            for (i = [0: angleStep: 360 - angleStep]) {
                rotate([0, 0, i]) {
                    translate([rPosK, 0, 0]) { cylinder(h = knobHeight, d = rK * 2, $fn = EDGE_QUALITY); }
                }
            }
        }

        for (i = [alpha: angleStep: 360]) {
            rotate([0, 0, i]) {
                translate([rPosN, 0, 0]) { cylinder(h = knobHeight, d = rN * 2, $fn = EDGE_QUALITY); }
            }
        }
    }
}

module lock(topLock = true) {
    difference() {
        lockBase(topLock);
        if (!topLock) {
            cylinder(h = protrusion, d = screwDiameter, $fn = 72);
        }
    }
}

module lockBase(topLock = true) {

    // lock width center to center:
    // screwHeadDiameter + 2 * screwDiameter
    // half: coordinates of the fixating cylinders
    lw = (screwHeadDiameter + 2 * screwDiameter) / 2;

    centerHeight = topLock ? headPerimeter : protrusion;

    cylinder(h = centerHeight, d = screwHeadDiameter, $fn = 72);
    translate([-lw, 0, 0]) { cylinder(h = knobHeight, d = screwDiameter, $fn = 72); }
    translate([lw, 0, 0]) { cylinder(h = knobHeight, d = screwDiameter, $fn = 72); }
    translate([-lw, -screwDiameter / 2, 0]) { cube([lw * 2, screwDiameter, headPerimeter]); }
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