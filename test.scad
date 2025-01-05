
// bei zehn ist schluss ohne Kompensation für die offsets (q = 120, ap = 2, nr = 4)
ARMS = 3;

// knobDiameter
// test: _knobDiameter = 40
_knobDiameter = 40;

// test: _q = 24
_q = 24;

// _quality muss ein Vielfaches von ARMS * 2 sein damit der Knopf symmetrisch wird
// nächstgrößere durch 2 * ARMS teilbare
_quality = ceil(_q / (ARMS * 2)) * ARMS * 2;

echo("quality", _quality);

// armPitch
// test: 3
// wenn der arm pitch zu hoch wird, werden die letzten Schichten der abgerundeten Kante zu Polygonen mit Intersections und dann stimmen die Indizes der Faces nicht mehr
// je mehr arme desto früher passiert das
_armPitch = 3;
// notchRatio
// test: 4
_notchRatio = 4;

// Radius der gerundeten Oberfläche
_topRadius = 40;

// Korrukturhöhe der Rundung
_heightOffset = _topRadius - 12;

// radius of the rounded edge
_edgeRadius = 2;

// Anzahl Schichten Rundung
_edgeLayerCount = floor(_quality / 4);


//difference() {
    test5();
//    cube(30);
//}

module test5() {
    // Aufbau in Schichten
    // erste Schicht liegt in der xy Ebene
    // zweite Schicht mit variablen z Werten
    // weitere Schichten: z-Wert der zweiten Schicht + sin (edgeAngle)

    kb = knobPoints(ARMS, _knobDiameter);

    n = len(kb);

    // base layer    
    bl = baseLayer(kb);

    // Schichten der runden Kante und Hilfsschicht für die obere Rundung
    layersTemp = edgeLayers(kb);
    lastLayer = layersTemp[len(layersTemp) - 1];
    topLayer = [[
        for (i = [0: len(lastLayer) - 1])
            lastLayer[i] + [0, 0, 10]
    ]];
    
    layers = concat(layersTemp, topLayer);
    
    points = concat(bl[0], flattenInnerList(layers));
    
    echo("len(points)", len(points));
    
    faces = concat (
        [ bl[1] ],

        // Seitenflächen und gerundete Kante: Vierergruppen über alle Layer
        // letzte schicht: Prisma nach oben für das Abziehen der Hohlkugel
        // faces werden von der Schicht unter der aktuellen zu dieser Schicht bestimmt
        // Achtung! Die Schicht mit der Nummer 0 ist hier nicht die unterste Schicht sondern die zweite Schicht. Deswegen stimmen die Indizes wenn die faces bei der untersten Schicht beginnend aufgebaut werden
        [
            for (i = [0: len(layers) - 1])
                let (abc = echo("i", i))
            
                let (count = len(layers[i]))
                let (countDiff = i == 0 ? 0 : len(layers[i - 1]) - count)

                let (pts =
                countDiff == 0 ?
                    // normale Schicht
                    let (start = firstPointIndex(layers, i))
                    let (def = echo("normal start", start))
                    
                    [for (j = [start: start + count - 1]) [
                        j,
                        (j + 1) % n + i * n,
                        (j + 1) % n + (i + 1) * n,
                        j + n
                    ]]
                    
                :
                    // reduzierende Schicht
                    
                    // gehe über die Schicht unter(!) dieser weil die Anzahk reduziert ist
                    let (lowerLayer = layers[i - 1])
                    let (start = firstPointIndex(layers, i))
                    let (cnt = len(lowerLayer))
                    let (closestPoints =
                        [ for (j = [0: cnt - 1])
                            closestToPoint(layers[i], layers[i - 1][j]) + start + len(bl[0])
                        ])

                    let (def = echo("reduced start", start))
                    [for (j = [start: start + cnt - 1])
                        let (cp = closestPoints[j - start])
                        let (next = (j + 1) % cnt + start)
                        let (cpNext = closestPoints[next - start])
 
                        let (abc = echo("cp", j, cp, next, cpNext))

                        cp == cpNext ? [ j, next, cp ] : [ j, next, cpNext, cp]

                    ]
                )
                each pts
        ],

/*
    // for each point of the previous layer find the closest of these points
    closestPoints = [ for (i = [0: len(lastLayer) - 1]) closestToPoint(ptst, lastLayer[i]) ];

        // gerundete Schichten auf der Oberseite
        // beginne mit der letzen Schicht der Rundung
        let (start = layers * n)
        let (abc = echo("start", start))
        let (offset = len(pts) - len(ptst))
        [
            // gehe über die letzte Schicht der Rundung
            for (i = [start: start + n - 1])
                let (cp = closestPoints[i - start] + offset)
                let (next = (i + 1) % n + start)
                let (cpNext = closestPoints[next - start] + offset)
                cp == cpNext ? [ i, next, cp ] : [ i, next, cpNext, cp]
        ],

/**/
        // Oberseite: letzte n punkte reversed
        [[ for (i = [(_edgeLayerCount + 2) * n - 1: -1: (_edgeLayerCount + 1) * n]) i ]]
    );

    render() color("gold") difference() {
        polyhedron(points, faces, convexity = 10);
//        translate([0, 0, -_heightOffset + 1]) hollowSphere(_topRadius + 20, _topRadius, $fn = _quality * 2);
    }
}

// for a given layer returns the total index of the first point
// e. g: layer 0: 24 points, layer 1: 18 points, layer 2: 18 points
// total index of layer 2 is 42: 24 + 18
function firstPointIndex(layers, i) = fPI_(layers, 0, i, 0);

// recursive helper for firstPointIndex
function fPI_(layers, i, target, sum) = 

let (abc = echo("fpi", i, len(layers[i]), sum))
    i == target ? sum : fPI_(layers, i + 1, target, sum + len(layers[i]));

module hollowSphere(outerRadius, innerRadius) {
    difference() {
        sphere(outerRadius);
        sphere(innerRadius);
    }
}

// gets a list with points in 2D (only x and y values)
// returns a list with two sublists: [ points, faces ]
function baseLayer(points) =
[
    // set the height of all points to 0
    [
        for (i = [0: len(points) - 1]) [ points[i].x, points[i].y, 0]
    ],
    
    // the base layer has just one face: all points clockwise
    [
        for (i = [0: len(points) - 1]) i,
    ]
];

// returns a list with the points of layer layerN in ccw order seen from above
// points: outmost edge
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

// generates a list of lists for all edge layers:
// [ [l0p0, l0p1, ..., l0pn-1], ... [lmp0, lmp1, ..., lmpn-1] ]
// due to self intersections appearing when offsetting the outline, the layers
// may have different numbers of points (the higher the less points)
function edgeLayers(points) =
[
    for (i = [0: _edgeLayerCount - 1])            
         edgeLayer(points, i)
];

// recursive helper for edgeLayers
function eL_() = 0;

// faces: closestto point nur wenn die layer verschiedene punktanzahlen haben

function heightAtEdge(p, angle) =
    heightAtTop(p) - _edgeRadius * (1 - sin(angle));

function pointHeightEdge(p, angle) = [p.x, p.y, heightAtEdge(p, angle)];

function heightAtTop(p) =
    sqrt(_topRadius^2 - norm([p.x, p.y])^2) - _heightOffset;

function pointHeightTop(p) = [p.x, p.y, heightAtTop(p)];

// generates points for the outher edge of the knob
// returns an array [ [x1, y1], [x2, y2] ... [xn, yn] ]
function knobPoints(arms, diameter) =

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
    
 // Länge des Bogens auf dem Umfang
// arms * (Bogen arm + Bogen notch)
// Winkel Bogen arm:  2 * (PI - beta)
// Winkel Bogen notch: 2 * gamma
// Bogen arcArm = degToRad(2 * (180 - beta)) * rK
// Bogen arcNotch = degToRad(2 * gamma) * rN
// Schritte pro segment: 360 / arms
// Anteil Arm: armShare = arcArm / (arcArm + arcNotch)
// Schritte pro Arm: armSteps = 360 / arms * armShare
// Schritte pro Notch: notchSteps = 360 / arms - armSteps
      
    let (arcArmMM = degToRad(2 * (180 - beta)) * rK)

    let (arcNotchMM = degToRad(2 * gamma) * rN)
    
    let (armShare = arcArmMM / (arcArmMM + arcNotchMM))

    let (armSteps = round(_quality / ARMS * armShare))
    
    let (armAngleStep = 2 * (180 - beta) / armSteps)
    
    let (notchSteps = _quality / ARMS - armSteps)
    
    let (notchAngleStep = 2 * gamma / notchSteps)

// über alle Arme
[
for (phi = [0: angleStep: ARMS * angleStep - 1])
    let (armX = rPosK * cos(phi))
    let (armY = rPosK * sin(phi))

    let (armStartAngle = phi - (180 - beta))

    let (notchX = rPosN * cos(phi + angleStep / 2))
    let (notchY = rPosN * sin(phi + angleStep / 2))

    let (notchStartAngle = phi + angleStep / 2 + 180 + gamma)

    each concat(
        // über den Arm
        [for (i = [0: 1: armSteps - 1])
            let (phi2 = armStartAngle + i * armAngleStep)

            [
                armX + rK * cos(phi2),
                checkAndSetToZero(armY + rK * sin(phi2))
            ]
        ],
    
        // über die Notch
        [for (i = [0: 1: notchSteps - 1])
            // center liegt außen, laufen im Uhrzeigersinn
            let (phi2 = notchStartAngle - i * notchAngleStep)
            
            [
                notchX + rN * cos(phi2),
                checkAndSetToZero(notchY + rN * sin(phi2))
            ]
        ]
    )
];

// eliminates the intersections from the given polygon
// ATTENTION! This function is designed to be fast on the rotationally
// symmetric geometry of the knobs. It does not work for the general case.
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
    
    let (pts = [for (i = [0: 1: lastIndex])
        points[(startIndex + i) % len(points)]]
    )
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
    // don't mirror the first point if it ends on the x-axis after being rotated by 360 / ARMS / 2 degrees
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
    p2.y < 0
        // line (p1, p2) belongs to the poly, add the second point and go on
        ? pPFA_(points, i + 1, concat(result, [p2]))
        // the second point is on the other side of the x-axis,
        // we add the intersection of the line (p1, p2) with the x-axis to the result and leave
        : concat(result, [[ p1.x - p1.y * (p2.x - p1.x) / (p2.y - p1.y), 0]])
;

// finds the point closest to the center
// returns the index of the closest point
//function closestToCenter(points) = cTC_(points, 0, norm(points[0]), 0);
function closestToCenter(points) = closestToPoint(points, [0, 0]);

// finds the point of the list points that is closest to a given point p
// returns the index
function closestToPoint(points, p) = cTP_(points, p, 0, norm(p - points[0]), 0);

// recursive helper for closestToPoint()
function cTP_(points, p, index, min, minIndex) = 
    index == len(points) ? minIndex :

        let (distance = norm(p - points[index]))
        // we need the very last smallest distance to get the correct index
        let (delta = distance - min)
        let (m = distance < min || isActuallyZero(delta) ? distance : min)
        let (i = distance < min || isActuallyZero(delta) ? index : minIndex)

        cTP_(points, p, index + 1, m, i);    

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
        p.x + l * bis.x,
        checkAndSetToZero(p.y + l * bis.y)
    ]
];

function rotatePointsAroundZAxis(points, angle) =
[
    for (i = [0: 1: len(points) - 1])
        rotatePointAroundZAxis(points[i], angle)
];


function rotatePointAroundZAxis(point, angle) =
    [
        [cos(angle), -sin(angle)],
        [sin(angle),  cos(angle)]
    ]
    * point
;

function checkAndSetToZero(x) = isActuallyZero(x) ? 0 : x;

function isActuallyZero(x) = abs(x) < 1e-10;
    
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

function flattenInnerList(list) = [for (i = [0: len(list) - 1]) each list[i]];