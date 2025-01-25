/**
 * Creates handles for hexagon head screws, Allen / Inbus screws and hexagonal nuts.
 * Various parameters can be controlled:
 * SIZE: M4, M5, M6, M8, the arrays can be extended for further sizes
 * TYPE: knob for hex nut / screw, with or without hub, allen screw with lockhub
 * SHAPE: flat or rounded top
 * ARMS: number of "arms" of the star shaped knob
 * QUALITY: smoothness of the rendered stl (related but not equal to OpenSCAD $fn value)
 *
 * A lockhub is a hub with a cutout for a hex nut. There is always a lockhub for Allen /
 * Inbus screws because the screw must be countered with a lock nut in order to be
 * tightened. This type of lockhub cannot be part of the knob for hex screws in the 
 * first place because the screw cannot be turned in the knob in order to tighten it
 * against the lock nut. Thus, knobs for hex screws have a hub with just a cylindrical
 * hole for the threaded shaft. This is usually not critical since the screw is pulled
 * into the knob anyway when tightened.
 * If a hex screw still needs to be secured in the knob permanently, the knob can be
 * printed without a hub and a lockhub can be printed separately, which is then used like
 * a lock nut.
 *
 * Note, that further values, e. g. distance and size of the arms, depth
 * of the recesses (notches), radius of the rounded edge, and the size of the
 * hub can be modified in the source code.
 *
 * All dimensions in mm.
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
// size of the metric screw / nut or free: if you select "free" customize the detailed values in the Dimensions Tab below
SIZE = "free"; // [M3, M4, M5, M6, M8, M10, M12, M14, M16, free]

// TYPE possible values:
// - hex: make a knob with hub for a hex nut or screw
// - hexnohub : make a knob without hub hub for a hex nut or screw (if you want to use a lockhub)
// - allen: make a knob with hub for an Allen screw with lock nut in the hub
// - inbus: make a knob with hub for an Allen screw with lock nut in the hub, is the same as allen, convenience option for German users
// - lockhub: make a standalone hub with a cutout for a nut. This can be used as a lock nut for screwx knobs
// what should be made
TYPE = "hex"; // [hex, allen, inbus, hexnohub, lockhub]

// shape of the top surface
SHAPE = "rounded"; // [flat, rounded]

// number of arms
ARMS = 5;

// Diameter of the knob in relation to the screw diameter
DIAMETER_RATIO = 7; // [5 : 15]

// 360 gives a smooth finish
// The higher the smoother the finish, the higher the computing time. Use very small values for a low poly look. Very high values probably only make sense for very large knobs (100mm diameter and above)
QUALITY = 360; // [24 : 720]

// The values in the Dimensions tab have only to be customized if you choose the SIZE value "free"
/* [Dimensions:] */
THREAD_DIAMETER = 8.0; // .01

// Attention! This NOT the wrench size but the diameter of the head measured across the corners
HEX_SCREW_NUT_HEAD_DIAMETER_ACROSS_CORNERS = 14.38; // .01

HEX_SCREW_NUT_HEIGHT = 6.8; // .01

ALLEN_HEAD_DIAMETER = 13.0; // .01

ALLEN_HEAD_HEIGHT = 8.0; // .01

/*********** END PARAMETERS ***********/

/*****************************************
 * START CALCULATED VALUES
 * change to get differently shaped knobs
 *****************************************/

 /* [Hidden] */
 
 /**
 * Measures of metric screws and nuts according to
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
// size, screwDiameter (d1), screwHeadDiameter (e), screwHeadHeight (k / m), allenHeadDiameter (dk), allenHeadHeight (k)
//
// Note that the screwHeadDiameter is the largest dimension, NOT the wrench size.
// In DIN and ISO dimension tables, this dimension is usually designated as e.
//     ___
//    /   \
//    \___/
//    --e--
// dimensions from DIN 933 / ISO 4017 and DIN 912 / ISO 4762 (inbus / allen)
// The height dimension (k / m) is parameter m from DIN 934 / ISO 4032 for nuts.
// Nuts are a little higher than screw heads, thus screws will sit a little deeper.
// Change this value if necessary.
// [size, d1, e, k / m, inbus dk, inbus k]
screws = [
    [ "M3",  3,  6.01,  2.4,  5.5,  3],
    [ "M4",  4,  7.66,  3.2,  7.0,  4],
    [ "M5",  5,  8.79,  4.7,  8.5,  5],
    [ "M6",  6, 11.05,  5.2, 10.0,  6],
    [ "M8",  8, 14.38,  6.8, 13.0,  8],
    ["M10", 10, 18.90,  8.0, 16.0, 10],
    ["M12", 12, 21.10, 10.0, 18.0, 12],
    ["M14", 14, 24.49, 11.0, 21.0, 14],
    ["M16", 16, 26.75, 13.0, 24.0, 16],
    
    // TODO
    // US dimensions according to ASME B18.2.1, ASME B18.2.2 
    // name, thread size, head diameter across corners (e), head height (h), allen head diameter, allen head height]
    // ["5/32"]
    // ["3/16"]
    // ["1/4",  1/4 * 25.4, 0.505, 5/32 * 25.4, 3/8 * 25.4, 1/4 * 25.4]
    // ["5/16", 5/16 * 25.4, 0.577, 7/32 * 25.4]
];

// get the measures from the array or from the Customizer view
screw = SIZE != "free"
    ? selectScrew(SIZE)
    : [
        "free",
        THREAD_DIAMETER,
        HEX_SCREW_NUT_HEAD_DIAMETER_ACROSS_CORNERS,
        HEX_SCREW_NUT_HEIGHT,
        ALLEN_HEAD_DIAMETER,
        ALLEN_HEAD_HEIGHT
    ];

// _quality must be a multiple of ARMS * 2 to have the body rotationally symmetrical
// next larger number divisible by 2 * ARMS
_quality = ceil(QUALITY / (ARMS * 2)) * ARMS * 2;

// Length of the screw shank that should be inside the knob
// note: the height of the hub is added to this value so that the actual protrusion
// is larger
protrusion = screw[1];

screwDiameter = screw[1];
screwHeadDiameter = TYPE == "allen" || TYPE == "inbus" ? screw[4] : screw[2];
screwHeadHeight = TYPE == "allen" || TYPE == "inbus" ? screw[5] : screw[3];
nutDiameter = screw[2];

// smoothness of the knob's edges. The hub's radius is half of this size to
// compensate for oversized holes in the part this knob is screwed to
_edgeRadius = screwDiameter / 4;

// size of the knob, can alternatively be set to a constant value
_knobDiameter = screwDiameter * DIAMETER_RATIO;

// pitch of the arms: a pitch of one means that one arm radius ist between two arms, a pitch of two means that two arm radii are between two arms. Since the circumference is constant this setting controls the radius of the arms: the larger the pitch, the smaller the arms. Sensible Values are 1, 2, 3
_armPitch = 1;

// ratio of arm diameter to notch diameter
// 2 means, notches have twice the radius of arms.
// The higher the notchRatio is, the flatter the notches are. Sensible values are between 2 and 5
_notchRatio = 2;

// TODO: rounded top, bottom edge radius
_knobBodyHeight = protrusion + screwHeadHeight - _edgeRadius;

// how much the top rounding stands above the top edge
topRoundingHeight = SHAPE == "flat" ? 0 : _knobDiameter / 12;

_topRadius = topRoundingHeight != 0
    ?
    // subtract a hollow sphere from the knob body
    // radius of the top rounding when viewing from above (parallel to the knob's circumference)
    let (rTopRoundingArch = _knobDiameter / 2 - _edgeRadius)
    // distance from the center of the hollow sphere to the knob's surface without the rounding
    let (distCenterSurface = (rTopRoundingArch^2 - topRoundingHeight^2) / (2 * topRoundingHeight))

    distCenterSurface + topRoundingHeight

    : 0;

// z-offset to compensate for the rounded top surface beeing in the origin
// TODO: calculate from the dimensions of the knob (e. g. height of the screw head)
_heightOffset = _topRadius - _knobBodyHeight;

// size of the hub
_hubHeight = screwDiameter * 1.2;

// the hub has at least a wall thickness at the nut of the thread's radius
_hubDiameter = screwHeadDiameter + screwDiameter;

// number of layers of the rounded edge, must at least be two
// note: layers of points, one larger than the resulting numer of layers of faces
elTemp = round(_quality * _edgeRadius / _knobDiameter);
_edgeLayerCount = elTemp >= 2 ? elTemp : 2;

// configure the knob
makeHub = TYPE == "hex" || TYPE == "allen" || TYPE == "inbus";

// make the thing
// parameter slot for future improvements
render() color("gold")
if (TYPE == "lockhub") {
    hub(nut = true, slot = false);
} else {
    knob(makeHub);
}

module knob(makeHub = false) {

    difference() {
        translate([0, 0, _edgeRadius]) knobBody();
        
        // cut hole for screw shaft
        cylinder(h = _knobBodyHeight, d = screwDiameter, $fn = 72);

        // for allen screws make a circular cutout
        // for  hex screws and nuts make a hexagonal cutout
        edges = TYPE == "allen" || TYPE == "inbus" ? _quality : 6;
        
        // position of cutout with respect to the shape
        // TODO: remove after fixing _knobBodyHeight optimisation
        cutOffset = SHAPE == "rounded" ? _edgeRadius : 0;
        
        translate([0, 0, _knobBodyHeight - screwHeadHeight + cutOffset])
            cylinder(h = screwHeadHeight, d = screwHeadDiameter, $fn = edges);
    }
    
    // make a hub
    if (makeHub) {
        // if the knob is for allen screws the hub has a cutout for the lock nut
        rotate([180, 0, 0]) hub(nut = TYPE == "allen" || TYPE == "inbus");
    }
}

// creates the body
module knobBody() {
    // built out of layers basically parallel to the xy plane

    // 2D (x, y) points along the outer limit, ccw seen from above
    kb = limitPoints(ARMS, _knobDiameter);

    // layers of the bottom rounded edge
    bottomEdgeLayers = bottomEdgeLayers(kb);

    // layers of the top rounded edge plus an elevated copy of the last
    // layer to allow for subtracting a hollow sphere to make the rounding
    topEdgeLayers = topEdgeLayersRound(kb);
    
    // eleveated layer if top surface is rounded
    elevatedTopLayer = SHAPE == "rounded"
        ? let (lastLayer = topEdgeLayers[len(topEdgeLayers) - 1])
    
        [[
            for (i = [0: len(lastLayer) - 1])
                [lastLayer[i].x, lastLayer[i].y, _knobBodyHeight]
        ]]
        : [];

    // list of all layers, each layer is itself a list of 3D points
    layers = concat(bottomEdgeLayers, topEdgeLayers, elevatedTopLayer);
    
    // all points in a flat list for polyhedron
    points = flattenInnerList(layers);
    
    faces = createFaces(layers);

    // create a polyhedron with a prism-shaped extension at the top and
    // intersect it with a sphere representing the top rounding    
    intersection() {
        polyhedron(points, faces, convexity = 10);
        if (SHAPE == "rounded") {
            translate([0, 0, -_heightOffset]) sphere(_topRadius, $fn = _quality);
        }
    }
}

module hub(nut = false, slot = false) {
    eR = _edgeRadius / 2;
    q = _quality / 4;
    difference() {
        minkowski() {
            sphere(eR, $fn = q);

            // -eR: compensate for the enlargement by the minkowski sum
            cylinder(h = _hubHeight - eR, d = _hubDiameter - 2 * eR, $fn = q);
        }
        // cut hole for the screw
        cylinder(h = _hubHeight + eR * 2, d = screwDiameter, $fn = q);

        // cut off excessive height from minkowski sum
        translate([0, 0, -eR])
            cylinder(h = eR, d = _hubDiameter + eR * 2, $fn = q);

        if (nut) {
            nutPosZ = slot ? 0 : _hubHeight - screwHeadHeight - 1;
        
            // cut off hexagonal hole for the securing nut
            // -1 / +1: additional depth for printing tolerances
            translate([0, 0, nutPosZ])
                cylinder(h = screwHeadHeight + 1, d = nutDiameter, $fn = 6);
            
            // cut off slot to insert the nut sideways
            if (slot) {
                translate([nutDiameter / 2, 0, 0])
                    // use a second cylinder to avoid calculating the width of the slot
                    cylinder(h = nutHeight + 1, d = nutDiameter, $fn = 6);
            }
        }
    }
}


/*************************************
 * knob related functions and modules
 *************************************/

// generates points for the outher edge of the knob
// returns a list [ [x1, y1], [x2, y2] ... [xn, yn] ]
function limitPoints(arms, diameter) =

    // radius of the knob
    let (rKnob = diameter / 2)

    // radius of the arm circles
    let (rK = PI * rKnob / ((_armPitch + 1) * ARMS + PI))
    // radius of the notch circles
    let (rN = _notchRatio * rK)

    // radius of the circle to place the arms (rbk)
    let (rPosK = rKnob - rK)

    // angle between arm and notch (360 / ARMS / 2)
    let (alpha = 180 / ARMS)

    // angle between center of knob, center of notch, center of arm
    let (gamma = asin(sin(alpha) * rPosK / (rN + rK)))

    // angle between center of knob, center of arm, center of notch
    let (beta = 180 - alpha - gamma)

    // radius of the circle to place the notches (rbn)
    let (rPosN = abs(rPosK * sin(beta) / sin(gamma)))

    // radius of the knob's core: distance from center to touch point of arm and notch (rc)
    let (rCore = sqrt(rPosK^2 + rK^2 - 2 * rPosK * rK * cos(beta)))

    // angle to touch point
    let (alphaC = asin(rK * sin(beta) / rCore))

    // angle of one arm: tip and notch
    let (angleStep = 360 / ARMS)
    
    // length of an arm's arc
    let (arcArmMM = degToRad(2 * (180 - beta)) * rK)

    // length of a notch's arc
    let (arcNotchMM = degToRad(2 * gamma) * rN)
    
    // share of the arm in the entire sector (arm and notch) 
    let (armShare = arcArmMM / (arcArmMM + arcNotchMM))

    // steps per arm
    let (armSteps = round(_quality / ARMS * armShare))
    
    // angle per step
    let (armAngleStep = 2 * (180 - beta) / armSteps)
    
    // steps per notch
    let (notchSteps = _quality / ARMS - armSteps)
    
    // angle per step
    let (notchAngleStep = 2 * gamma / notchSteps)

// loop over all arms
[for (phi = [0: angleStep: ARMS * angleStep - 1])
    
    // center of the arm
    let (armX = rPosK * cos(phi))
    let (armY = rPosK * sin(phi))

    let (armStartAngle = phi - (180 - beta))

    // center of the notch
    let (notchX = rPosN * cos(phi + angleStep / 2))
    let (notchY = rPosN * sin(phi + angleStep / 2))

    let (notchStartAngle = phi + angleStep / 2 + 180 + gamma)

    // note checkAndSetToZero: when ofsetting the outer edge we occasionally check if a 
    // point is on the x axis, thus the y value is set to zero if it is very likely 
    // actually zero but differs due to floating point errors
    each concat(
        // loop over the arm
        [for (i = [0: 1: armSteps - 1])
            let (phi2 = armStartAngle + i * armAngleStep)
            [
                checkAndSetToZero(armX + rK * cos(phi2)),
                checkAndSetToZero(armY + rK * sin(phi2))
            ]
        ],
    
        // loop over the notch
        [for (i = [0: 1: notchSteps - 1])
            // center is outside, thus need to go clockwise
            let (phi2 = notchStartAngle - i * notchAngleStep)
            [
                checkAndSetToZero(notchX + rN * cos(phi2)),
                checkAndSetToZero(notchY + rN * sin(phi2))
            ]
        ]
    )
];

// generates a list of lists for all bottom edge layers:
// [ [l0p0, l0p1, ..., l0pn-1], ... [lmp0, lmp1, ..., lmpn-1] ]
function bottomEdgeLayers(points) =
[
    for (i = [0: _edgeLayerCount - 1])            
         bottomEdgeLayer(points, i)
];

// creates one layer of the rounded bottom edge
function bottomEdgeLayer(points, layerN) =
    // angle of this layer's edge rounding
    // we have one angle step less than the number of edge layers:
    // layer 0 is at -90 degrees (bottom)
    // layer _edgeLayerCount - 1 is at 0 degrees (outmost edge)
    let (angle = -90 / (_edgeLayerCount - 1) * (_edgeLayerCount - layerN - 1))
    
    // horizontal distance of the current layer from the outer edge
    let (horDist = _edgeRadius * (1 - cos(angle)))


    // (x, y) - points of the current layer, as offset from the outmost edge
    let (layerPoints = polyEliminatedIntersections(
        offsetPoly(points, -horDist))
    )
    
    // calculate the heights of the points, depending on the current angle
    // and the distance of the point from the center
    [for (i = [0: len(layerPoints) - 1])
        [ layerPoints[i].x, layerPoints[i].y, _edgeRadius * sin(angle) ]
    ]
;

// generates a list of lists for all top edge layers:
// [ [l0p0, l0p1, ..., l0pn-1], ... [lmp0, lmp1, ..., lmpn-1] ]
// due to self intersections appearing when offsetting the outline, the layers
// may have different numbers of points (the higher the less points)
function topEdgeLayersRound(points) =
[
    for (i = [0: _edgeLayerCount - 1])            
         topEdgeLayerRound(points, i)
];

// returns a list with the points of layer layerN in ccw order seen from above
// points: outer limit of the knob
function topEdgeLayerRound(points, layerN) =
    // angle of this layer's edge rounding
    // we have one angle step less than the number of edge layers:
    // layer 0 is at 0 degrees (horizontal)
    // layer _edgeLayerCount - 1 is at 90 degrees (vertical)
    let (angle = 90 / (_edgeLayerCount - 1) * layerN)
    
    // horizontal distance of the current layer from the outer edge
    let (horDist = _edgeRadius * (1 - cos(angle)))

    // (x, y) - points of the current layer, as offset from the outmost edge
    let (layerPoints = polyEliminatedIntersections(
        offsetPoly(points, -horDist))
    )
    
    // calculate the heights of the points, depending on the current angle
    // and the distance of the point from the center
    [for (i = [0: len(layerPoints) - 1])
        // height of the point with respect to surface rounding and edge rounding
        pointHeightEdge(layerPoints[i], angle)
    ]
;

function heightAtTopEdge(p, angle) =
    heightAtTop(p) - _edgeRadius * (1 - sin(angle));

// sets the z value of the point to the according height (rounded edge)
function pointHeightEdge(p, angle) = [p.x, p.y, heightAtTopEdge(p, angle)];

function heightAtTop(p) =
    SHAPE == "rounded"
    ? sqrt(_topRadius^2 - norm([p.x, p.y])^2) - _heightOffset
    : _knobBodyHeight - _edgeRadius;

// sets the z value of the point to the according height (rounded top surface)
function pointHeightTop(p) = [p.x, p.y, heightAtTop(p)];

// for a given layer returns the total index of the first point
// e. g: layer 0: 24 points, layer 1: 18 points, layer 2: 15 points
// total index of layer 2 is 24 + 18 = 42
function firstPointIndex(layers, i) = fPI_(layers, 0, i, 0);

// recursive helper for firstPointIndex
function fPI_(layers, i, target, sum) =
    i == target ? sum : fPI_(layers, i + 1, target, sum + len(layers[i]));

/****************************************************************
 * more or less general functions and modules to handle polygons
 ****************************************************************/

// create the faces from bottom to top in three steps:
// one face defined by the bottom layer
// n faces defined by following layers
// one face defined by the top layer
// TODO: split into functions
// TODO: top / bottom layers with less than three points are not handled yet
// (towards a general solution). The basic principle is already implemented,
// we probably just need to test for the number of points in the first and last
// layer and adjust the loops accordingly
function createFaces(layers) = concat (
    // bottom face: points of the first layer ccw
    // double square brackets: concat unfolds for whatever reason
    [[ for (i = [0: len(layers[0]) - 1]) i ]],

    // layers of the sides along the z axis
    [
        // -2: there is one layer of side faces less than layers of points
        for (i = [0: len(layers) - 2])
            let (count = len(layers[i]))
            let (nextCount = len(layers[i + 1]))
            
            // check if the next layer has the same number of points
            let (countDiff = nextCount - count)

            let (start = firstPointIndex(layers, i))
            let (pts =
            countDiff == 0 ?
                // layers have the same number of points, make squares
                // TODO: towards a general solution: if the layers are twisted 
                // against each other this step might utilize the closestToPoint function
                // make a square, go clockwise from the bottom left point
                [for (j = [start: start + count - 1]) [
                    j,
                    j + count,
                    (j - start + 1) % count + start + count,
                    (j - start + 1) % count + start
                ]]
            :
            let (nextLayer = layers[i + 1])
            countDiff < 0 ?
                // layer has more points than the layer above
                // for every point of this layer find the closest point in the layer 
                // above, easier than messing around with indizes of deleted points 
                // and a more general solution
                let (closestPoints =
                    [ for (j = [0: count - 1])
                        closestToPoint(nextLayer, layers[i][j]) + start + count
                    ])

                // if for two neighboring points of this layer the closest points
                // in the layer above
                // #1: are the same: make a triangle
                // #2: are neighbors: make a square
                // #3: have another point (cpn) inbetween: make a triangle AND a square
                flattenInnerList(
                [for (j = [start: start + count - 1])
                    let (cp = closestPoints[j - start])
                    // the point after the cp
                    let (cpn = (cp - start - count + 1) % nextCount + start + count)
                    let (next = (j - start + 1) % count + start)
                    // the cp of the next point in this layer
                    let (cpNext = closestPoints[next - start])

                    cp == cpNext
                        ? [[ j, cp, next ]]
                    : cpNext == cpn
                        ? [[ j, cp, cpNext, next]]
                    : [[j, cp, cpn], [j, cpn, cpNext, next]]
                ])
            :
                // layer has fewer points than the layer above
                // use the same procedure as before but go along the layer above 
                // instead of along this layer
                let (closestPoints =
                    [ for (j = [0: nextCount - 1])
                        closestToPoint(layers[i], nextLayer[j]) + start
                    ])

                let (startNext = start + count)
                flattenInnerList(
                [for (j = [startNext: startNext + nextCount - 1])
                    let (cp = closestPoints[j - startNext])
                    let (cpn = (cp - start + 1) % count + start)
                    let (next = (j - startNext + 1) % nextCount + startNext)
                    let (cpNext = closestPoints[next - startNext])

                    cp == cpNext
                        ? [[ j, next, cp ]]
                    : cpNext == cpn
                        ? [[ j, next, cpNext, cp]]
                    : [[j, cpn, cp], [j, next, cpNext, cpn]]
                ])
            )
            // flatten the list
            each pts
    ],

    // top face: points of the last layer clockwise
    let (start = firstPointIndex(layers, len(layers) - 1))    
    let (end = start + len(layers[len(layers) - 1]) - 1)
    [[ for (i = [end: -1: start]) i ]]
);

// eliminates the intersections from the given polygon
// ATTENTION! This function is designed to be fast on the rotationally
// symmetric geometry of the knobs. It does not work for the general case.
// the idea is to find the closest point to the center and use this as
// starting point. Due to the rotational symmetry of the knob there are
// several closest points (one or two per notch). We furthermore know that
// the first arm is mirrored on the x-axis. So we use that starting point
// which is the last one before the first arm starts. The first arm starts
// at index 0, so the closest point we want to use is the one with the highest
// index. From that starting point we check the edges of the polygon towards
// the x-axis. We either find (i) an edge crossing the x-axis or (ii) a point
// laying on the x-axis (having a 0 y value).
// Either of these points (the intersection with the x-axis or the regular
// point on the x-axis) mark the last point we might take.
// These points are first mirrored at the x-axis to have a full arm and then
// rotated around the z-axis arm times to make the full outer limit of the knob.
function polyEliminatedIntersections(points) = 

    // we need to check only one arm, the remainder is symmetric
    let (n = len(points) / ARMS)

    // find last point that is closest to the center, this must be the middle
    // of the notch before (ccw) the first tip
    
    let (startIndexTemp = closestToCenter(points))
    // always use the first arm
    let (startIndex = startIndexTemp % n + (ARMS - 1) * n)    
    
    // take the last point only if it is on the x-axis, otherwise
    // we don't want to calculate the intersection of the last edge with
    // the x-axis
    let (lastIndex = points[(startIndex + n / 2) % len(points)].y == 0 ? n / 2 : n / 2 - 1)
    
    // make the list of the points that need to be checked for intersections
    let (pts = [for (i = [0: 1: lastIndex])
        points[(startIndex + i) % len(points)]]
    )
    // get the points of the first arm
    let (ppfa = polyPointsFirstArm(pts))
    
    let (result = [
        for (i = [0: ARMS - 1])
            each rotatePointsAroundZAxis(ppfa, i * 360 / ARMS)
    ])

    // how many points were removed
    len(points) - len(result) == 0
        // result is rotated clockwise by startIndex steps
        ? rotateList(result, startIndex)
        :
        // result must be rotated such that close points align
        let (closestTo0 = closestToPoint(result, points[0]))
        rotateList(result, len(result) - closestTo0)
;

// finds all points of the first arm that belong to the polygon without intersections
function polyPointsFirstArm(points) =
    let (firstHalf = concat([points[0]], pPFA_(points, 0, [])))
    
    // mirror the first half
    // don't mirror the first point if it ends on the x-axis after being
    // rotated by 360 / ARMS / 2 degrees
    let (firstPointRot = rotatePointAroundZAxis(firstHalf[0], 360 / ARMS / 2))
    let (sIndex = isActuallyZero(firstPointRot.y) ? 1 : 0)

    // don't mirror the last point if it is on the x axis
    let (lastPoint = firstHalf[len(firstHalf) - 1])
    let (eIndex = lastPoint.y == 0 ? len(firstHalf) - 2 : len(firstHalf) - 1)
    let (secondHalf = [
        for (i = [eIndex: -1: sIndex])
            [firstHalf[i].x, -firstHalf[i].y]
    ])
    concat(firstHalf, secondHalf)
;

// recursive helper for polyPointsFirstArm()
function pPFA_(points, i, result) = 
// only need to go to the second to last point because the last line starts there
i == len(points) - 1
    ? result
    :
    let (p1 = points[i])
    let (p2 = points[i + 1])
    checkAndSetToZero(p2.y) < 0
        // line (p1, p2) belongs to the poly, add the second point and go on
        ? pPFA_(points, i + 1, concat(result, [p2]))
        // the second point is on the other side of the x-axis,
        // we add the intersection of the line (p1, p2) with the x-axis to the result 
        // and leave
        : concat(result, [[
            checkAndSetToZero(p1.x - p1.y * (p2.x - p1.x) / (p2.y - p1.y)),
            0
        ]])
;

// in a list of points finds the point closest to the center
// returns the index of the closest point
function closestToCenter(points) = closestToPoint(points, [0, 0]);

// in a list of points finds the point that is closest to a given point p
// returns the index of the closest point
function closestToPoint(points, p) = cTP_(points, p, 0, norm(p - points[0]), 0);

// recursive helper for closestToPoint()
function cTP_(points, p, index, min, minIndex) = 
    index == len(points) ? minIndex :

        let (distance = norm(p - points[index]))
        // we need the very last smallest distance to get the correct index
        let (delta = distance - min)
        let (m = distance < min || isActuallyZero(delta) ? distance : min)
        let (i = distance < min || isActuallyZero(delta) ? index : minIndex)

        cTP_(points, p, index + 1, m, i)
;    

// offsets a polygon
function offsetPoly(points, offset) =
let (n = len(points))
[
for (i = [0: 1: n - 1])
    // previous point
    let (pp = points[(i - 1 + n) % n])
    
    // this point
    let (p = points[i])
    
    // next point
    let (pn = points[(i + 1) % n])
    
    // vector from previous to this point
    let (va = p - pp)
    
    // vector from this to next point
    let (vb = pn - p)
    
    // normalized normal of va
    let (na = [va.y, -va.x] / norm([va.y, -va.x]))
    
    // normalized normal of vb
    let (nb = [vb.y, -vb.x] / norm([vb.y, -vb.x]))
    
    // normalized bisector of the normals
    let (bis = (na + nb) / norm(na + nb))
    
    // distance from vertex along bisector
    // see https://stackoverflow.com/a/54042831
    let (l = offset / sqrt((1 + na * nb) / 2))

    // offset point
    [
        checkAndSetToZero(p.x + l * bis.x),
        checkAndSetToZero(p.y + l * bis.y)
    ]
];

// rotates all points of the given list around the z axis by the angle
function rotatePointsAroundZAxis(points, angle) =
[
    for (i = [0: 1: len(points) - 1])
        rotatePointAroundZAxis(points[i], angle)
];

// rotates the given point around the z axis by the angle
function rotatePointAroundZAxis(point, angle) =
    let (pTemp = [
        [cos(angle), -sin(angle)],
        [sin(angle),  cos(angle)]
    ]
    * point)
    [
        checkAndSetToZero(pTemp.x),
        checkAndSetToZero(pTemp.y),
        pTemp.z
    ]
;

/*******************
 * helper functions
 *******************/

EPSILON = 1e-10;

function checkAndSetToZero(x) = isActuallyZero(x) ? 0 : x;

function isActuallyZero(x) = abs(x) < EPSILON;
    
function degToRad(degrees) = degrees * PI / 180;

function radToDeg(radians) = radians * 180 / PI;

// returns a part of a list, including start and end
function partialList(list, start, end) = [for (i = [start: end]) list[i]];

// returns a list reversed
function reversedList(list) = [for (i = [len(list) - 1: -1: 0]) list[i]];

// rotates the list by n elements to the right
function rotateList(list, n) = 
    let (count = len(list))
    let (sI = count - n % len(list))
[
    for (i = [0: count - 1])
        list[(sI + i) % count]
];

// flattens the inner lists of the given list
function flattenInnerList(list) = [for (i = [0: len(list) - 1]) each list[i]];





// selector functions to simplify the selection of the entities
function selectFromDict(item, dict) = dict[search([item], dict)[0]];

function selectScrew(size) = selectFromDict(size, screws);