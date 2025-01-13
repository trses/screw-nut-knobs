ARMS = 13;

// knobDiameter
_knobDiameter = 40;

// number of segments along the circumference
_q = 180;

// _quality must be a multiple of ARMS * 2 to have the body rotationally symmetrical
// next larger number divisible by 2 * ARMS
_quality = ceil(_q / (ARMS * 2)) * ARMS * 2;
echo("quality", _quality);

// 13 arms works with slight changes of the arm pitch (<= 1.96, >= 2.18 but not for == 3)
// it has nothing to do with the derived number of steps per arm / per notch
// since this doesn't change with the slight modifications
// armPitch
_armPitch = 3.1;

// notchRatio
_notchRatio = 4;

// radius of the top surface's rounding
// TODO: calculate from a given offset (height above the flat surface)
_topRadius = 40;

// z-offset to compensate for the rounded top surface beeing in the origin
// TODO: calculate from the dimensions of the knob (e. g. height of the screw head)
_heightOffset = _topRadius - 12;

// radius of the rounded edge
_edgeRadius = 2;

// number of layers of the rounded edge, must at least be two
// note: layers of points, one larger than the resulting numer of layers of faces
elTemp = round(_quality * _edgeRadius / _knobDiameter);
_edgeLayerCount = elTemp >= 2 ? elTemp : 2;

// make that thing
translate([0, 0, _edgeRadius]) color("gold") knobBody();

// creates the body
module knobBody() {
    // built out of layers basically parallel to the xy plane

    // 2D (x, y) points along the outer limit, ccw seen from above
    kb = limitPoints(ARMS, _knobDiameter);

    // layers of the bottom rounded edge
    bottomEdgeLayers = bottomEdgeLayers(kb);

    // layers of the top rounded edge plus an elevated copy of the last
    // layer to allow for subtracting a hollow sphere to make the rounding
    // TODO: make the rounding by creating layers
    layersTemp = edgeLayers(kb);
    lastLayer = layersTemp[len(layersTemp) - 1];
    topLayer = [[
        for (i = [0: len(lastLayer) - 1])
            [lastLayer[i].x, lastLayer[i].y, 20]
    ]];
    
    // list of all layers, each layer is itself a list of 3D points
    layers = concat(bottomEdgeLayers, layersTemp, topLayer);

    // all points in a flat list for polyhedron
    points = flattenInnerList(layers);
    
    // create the faces from bottom to top in three steps:
    // one face defined by the bottom layer
    // n faces defined by following layers
    // one face defined by the top layer
    // TODO: split into functions
    // TODO: top / bottom layers with less than three points are not handled yet
    // (towards a general solution). The basic principle is already implemented,
    // we probably just need to test for the number of points in the first and last
    // layer and adjust the loops accordingly
    faces = concat (
        // bottom face: points of the first layer ccw
        // double square brackets: concat unfolds for whatever reason
        [[ for (i = [0: len(layers[0]) - 1]) i ]],
//        [ for (i = [0: len(layers[0]) - 1]) [i, (i + 1) % len(layers[0]), len(points) ]],

        // layers of the sides along the z axis
        [
            // -2: there is one layer of side faces less than layers of points
            for (i = [0: len(layers) - 2])
                let (count = len(layers[i]))
                let (nextCount = len(layers[i + 1]))
                
                // check if the next layer has the same number of points
                let (countDiff = nextCount - count)

                let (start = firstPointIndex(layers, i))
let (abc = echo("start", start, "count", count, "nextCount", nextCount))
                let (pts =
                countDiff == 0 ?
                    // layers have the same number of points, make squares
                    // TODO: towards a general solution: if the layers are twisted 
                    // against each other this step might utilize the closestToPoint function
                    // make a square, go ccw from the bottom left point
                    [for (j = [start: start + count - 1]) [
                        j,
                        j + count,
                        (j - start + 1) % count + start + count,
                        (j - start + 1) % count + start
                    ]]
                :
                let (nextLayer = layers[i + 1])
                countDiff < 0 ?
let (abc = echo("i", i, "countDiff", countDiff))
                    // layer has more points than the layer above
                    // for every point of this layer find the closest point in the layer 
                    // above, easier than messing around with indizes of deleted points 
                    // and a more general solution
                    let (closestPoints =
                        [ for (j = [0: count - 1])
                            closestToPoint(nextLayer, layers[i][j]) + start + count
                        ])

                    // make a square ccw if for two neighboring points of this layer the 
                    // closest points in the layer above are different, make a triangle 
                    // otherwise
                    flattenInnerList(
                    [for (j = [start: start + count - 1])
                        let (cp = closestPoints[j - start])
                        let (cp1 = (cp - start - count + 1) % nextCount + start + count)
                        let (next = (j - start + 1) % count + start)
                        let (cpNext = closestPoints[next - start])
 
// wenn cpNext nicht cp + 1 ist:
// mach ein Dreieck j, cp, cp + 1 und ein Viereck j, cp + 1, cpNext, j + 1
 
                        cp == cpNext
                            ? [[ j, cp, next ]]
                        : cpNext == cp1
                            ? [[ j, cp, cpNext, next]]
                        : [[j, cp, cp1], [j, cp1, cpNext, next]]
                    ])
                :
let (abc = echo("i", i, "countDiff", countDiff))
                    // layer has fewer points than the layer above
                    // use the same procedure as before but go along the layer above 
                    // instead of along this layer
                    let (countNext = len(nextLayer))
                    let (closestPoints =
                        [ for (j = [0: countNext - 1])
                            closestToPoint(layers[i], nextLayer[j]) + start
                        ])

                    let (startNext = start + count)
                    flattenInnerList(
                    [for (j = [startNext: startNext + countNext - 1])
                        let (cp = closestPoints[j - startNext])
                        let (cp1 = (cp - start + 1) % count + start)
                        let (next = (j - startNext + 1) % countNext + startNext)
                        let (cpNext = closestPoints[next - startNext])
let (abc = i == 1 ? echo("j", j, "cp", cp, "cpNext", cpNext) : 0)
                        cp == cpNext
                            ? [[ j, next, cp ]]
                        : cpNext == cp1
                            ? [[ j, next, cpNext, cp]]
                        : [[j, cp1, cp], [j, next, cpNext, cp1]]
/*
                        cp == cpNext
                            ? [ j, next, cp ]
                            : [ j, next, cpNext, cp]
/**/
                    ])
                )
                // flatten the list
                each pts
        ],
/**/
        // top face: points of the last layer clockwise
        let (start = firstPointIndex(layers, len(layers) - 1))
        let (end = len(points) -  1)
        [[ for (i = [end: -1: start]) i ]]
/*
        // top face: points of the last layer clockwise
        let (start = firstPointIndex(layers, len(layers) - 1))
        let (end = len(points) -  2)
        let (count = len(layers[len(layers) - 1]))
        let (abc = echo("count", count, "start", start, "end", end))
        [ for (i = [start: end]) [i, len(points) - 1, (i + 1) % (count) + start] ]
/**/
    );

echo(len(layers[16]));

l0 = layers[0];

l1 = layers[1];

l2 = layers[2];

size = 0.03;
/*
color("red") {
    translate(l2[len(l2) - 2]) sphere(size, $fn = 18);
    translate(l2[len(l2) - 1]) sphere(size, $fn = 18);
    translate(l2[0]) sphere(size / 10, $fn = 18);
    translate(l2[1]) sphere(size / 10, $fn = 18);
    translate(l2[2]) sphere(size / 10, $fn = 18);
    translate(l2[3]) sphere(size, $fn = 18);
    translate(l2[4]) sphere(size, $fn = 18);
    translate(l2[5]) sphere(size, $fn = 18);
}

    translate(l1[len(l1) - 2]) color("cyan") sphere(size, $fn = 18);
    translate(l1[len(l1) - 1]) color("cyan") sphere(size / 20, $fn = 18);
    translate(l1[0]) color("skyblue") sphere(size / 20, $fn = 18);
    translate(l1[1]) color("blue") sphere(size / 20, $fn = 18);
    translate(l1[2]) color("cyan") sphere(size, $fn = 18);
    translate(l1[3]) color("cyan") sphere(size, $fn = 18);


/**/
 //   echo(points);
    
    // create a polyhedron with a prism-shaped extension at the top and subtract a 
    // hollow sphere from it
    // TODO: calculate the thickness of the hollow sphere based on the knob's size

/*
    polyhedron(points, faces, convexity = 10);    
//    polyhedron(concat(points, [[0, 0, -_edgeRadius]]), faces, convexity = 10);

/**/
    difference() {
        polyhedron(points, faces, convexity = 10);
        echo("test");
        translate([0, 0, -_heightOffset]) hollowSphere(_topRadius + 20, _topRadius, $fn = _quality * 2);
    }
/*
    union() {
        polyhedron(points, faces, convexity = 10);
        translate([50, 0, 0]) cube(20);
    }
/**/

/*
union() {
    translate([50, 0, 0]) cube(20);
    translate([0, 50, 0]) cube(20);
}
*/
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
echo ("as, ns, tot", armSteps, notchSteps, (armSteps + notchSteps) * ARMS)
    
    // angle per step
    let (notchAngleStep = 2 * gamma / notchSteps)

// loop over all arms
[
for (phi = [0: angleStep: ARMS * angleStep - 1])
    
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
function edgeLayers(points) =
[
    for (i = [0: _edgeLayerCount - 1])            
         edgeLayer(points, i)
];

// returns a list with the points of layer layerN in ccw order seen from above
// points: outer limit of the knob
function edgeLayer(points, layerN) =
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

function heightAtEdge(p, angle) =
    heightAtTop(p) - _edgeRadius * (1 - sin(angle));

// sets the z value of the point to the according height (rounded edge)
function pointHeightEdge(p, angle) = [p.x, p.y, heightAtEdge(p, angle)];

function heightAtTop(p) =
    sqrt(_topRadius^2 - norm([p.x, p.y])^2) - _heightOffset;

// sets the z value of the point to the according height (rounded top surface)
function pointHeightTop(p) = [p.x, p.y, heightAtTop(p)];

// for a given layer returns the total index of the first point
// e. g: layer 0: 24 points, layer 1: 18 points, layer 2: 15 points
// total index of layer 2 is 24 + 18 = 42
function firstPointIndex(layers, i) = fPI_(layers, 0, i, 0);

// recursive helper for firstPointIndex
function fPI_(layers, i, target, sum) =
    i == target ? sum : fPI_(layers, i + 1, target, sum + len(layers[i]));

// make a hollow sphere
module hollowSphere(outerRadius, innerRadius) {
    difference() {
        sphere(outerRadius);
        sphere(innerRadius);
    }
}

/****************************************************************
 * more or less general functions and modules to handle polygons
 ****************************************************************/

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