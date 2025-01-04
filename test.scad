

ARMS = 5;

// knobDiameter
// test: kd = 40
kd = 40;

// Problematik: letzte Schichten ufern aus
// tests: arms - quality - ap - nr
// 3 - 24 - 3 - 4
// 7 - 70 - 3 - 4

// quality muss ein Vielfaches von ARMS * 2 sein damit der Knopf symmetrisch wird
// test: quality = 30
// test2: quality = 36 (letzter Punkt im arm ja/nein)
// test3: 21
// test4: 54
q = 360;

// nächstgrößere durch 2 * ARMS teilbare
nHalf = ARMS * 2;

quality = ceil(q / nHalf) * nHalf;

echo("quality", quality);

// armPitch
// test: 3
ap = 3;
// notchRatio
// test: 4
nr = 4;




// difference() {
    test5();
//    cube(30);
//}

module test6() {
    difference() {
        cube([40, 40, 30], center = true);
        translate([0, 0, -28]) #hollowSphere(60, 40);
    }
}

module test5() {
    // Unterschied zu test4: folgt auch für die inneren Radien des gerundeten randes der Rundung der Oberseite. Efekt: es gibt keine Vertiefungen an den Armen

    // Aufbau in Schichten
    // erste Schicht liegt in der xy Ebene
    // zweite Schicht mit variablen z Werten
    // weitere Schichten: z-Wert der zweiten Schicht + sin (edgeAngle)
    
    // Radius der gerundeten Oberfläche
    rs = 40;
    
    // Korrukturhöhe der Rundung
    chr = rs - 12;
    
    // Radius der abgerundeten Kante
    re = 2;

    kb = knobPoints(ARMS, kd);

//    translate(kb[0]) cylinder(h = 15, d = 0.5, $fn = 18);
    
    n = len(kb);

    // unterste Schicht
    pb = [
        for (i = [0: len(kb) - 1])
        [kb[i].x, kb[i].y, 0]
    ];
    
    // zweite Schicht
    pc = [
        for (i = [0: len(kb) - 1])
            // radius des griffs an der aktuellen stelle
            // let (rx = norm(kb[i]))
            // höhe des Mittelpunkts des Kreises der Rundung an der aktuellen stelle
//            let (hm = sqrt((rs - re) ^ 2 - (rx - re) ^ 2))
            let (hm = heightAtTop(kb[i], rs) - re)

            [kb[i].x, kb[i].y, hm - chr]
    ];

    // Anzahl Schichten Rundung
    layers = 9;
    
    // Berechne Höhenwete wie für zweite Schicht für jeden neuen Radius
    // Ziehe echte zweite Schicht von diesen Höhenwerten ab
    // Addiere die Differenz zum tatsächlichen Wert der Rundung
    
    // Schichten der Rundung
    // Beginn bei 1 weil Schicht 0 der Rundung bereits in pc ist
    ptsm = [
        for (a = [1: layers - 1])
            let (angle = 90 / (layers - 1) * a)
            
            // horizontaler Abstand der aktuellen Schicht vom äußersten Rand
            let (radDist = -re + re * cos(angle))

            // (x, y) - Punkte der aktuellen Schicht
            let (kpx = offsetPoly(knobPoints(ARMS, kd), radDist))
            
            let (kp = polyEliminatedIntersections(kpx))

            // Höhe der Oberseitenrundung der aktuellen Schicht, Berechnung wie für den Z-Wert von pc aber mit den x,y-Positionen der aktuellen Schicht (kp)
            for (i = [0: len(kp) - 1])
                // höhe des Mittelpunkts des Kreises der Rundung an der aktuellen stelle
                // norm(kp[i]) ist der Radius des Griffs an der aktuellen Stelle
                let (hm = sqrt((rs - re) ^ 2 - (norm(kp[i]) - re) ^ 2))
                let (zOffset = (hm - chr) - pc[i].z)
                let (zValue = round((pc[i].z + re * sin(angle) + zOffset) * 10000) / 10000)
                
                let (zv = heightAtTop(kp[i], rs) - re + re * sin(angle))

                [kp[i].x, kp[i].y, zv - chr]
    ];

/*  
    npx = len(ptsm) / (layers - 1);

    for (i = [npx: 2 * npx - 1]) {
        pt = ptsm[i];
        translate(pt) color("cyan") cylinder(h = (i - npx + 1) / 2, d = 0.5, $fn = 18);
    }
/**    
    echo("22", ptsm[22]);
    echo("28", ptsm[28]);
/**/
    // Punkte auf der Rundung

    // erster Ansatz: hier weitere kreisförmige Schichten einbringen, beginnend bei Radius der Notches + radius der agerundeten Kante

    // Anzahl der Punkte in der letzten Schicht
    npx = len(ptsm) / (layers - 1);
    lastLayer = partialList(ptsm, len(ptsm) - npx, len(ptsm) - 1);
    
    echo(npx, len(ptsm));
    echo(lastLayer);

/*
    for (i = [0: len(lastLayer) - 1]) {
        translate(lastLayer[i]) color("cyan") cylinder(h = i / 2 + 1, d = 0.5, $fn = 18);
    }
/**/    
    // find the point closest to the center
    projected = [for (i = [0: npx - 1]) [lastLayer[i].x, lastLayer[i].y]];

    dist = norm(projected[closestToCenter(projected)]);
    
    steps = floor(dist / 2) - 1;
    echo("steps", steps, "dist", dist);
/*
    for (i = [0: steps - 1]) {
        kpt = polyEliminatedIntersections(offsetPoly(projected, -2 * (i + 1)));
        
        // for each point of the previous layer find the closest of these points
        closestPoints = [
            for (j = [0: len(lastLayer) - 1])
                closestToPoint(kpt, lastLayer[j])
        ];
        
        echo(closestPoints);
        
        echo("len kpt", len(kpt));
        translate([0, 0, 12 + i]) color("cyan") polygon(kpt);

        if (i  > -1) {
            for (i = [0: len(kpt) - 1]) {
                translate(kpt[i]) color("red") cylinder(h = i / 3 + 15, d = 0.5, $fn = 18);
            }
        }
    }
/**/

    ptst = [
        for (i = [0: steps - 1])
            // the next outline
            let (kpt = polyEliminatedIntersections(offsetPoly(projected, -2 * (i + 1))))

            // Höhe der Oberseitenrundung der aktuellen Schicht
            for (i = [0: len(kpt) - 1])
                let (h = heightAtTop(kpt[i], rs))

                [ kpt[i].x, kpt[i].y, h - chr]
    ];

    topLayer = [
        for (i = [0: len(lastLayer) - 1])
            lastLayer[i] + [0, 0, 10]
    ];

    pts = concat(pb, pc, ptsm, topLayer, [[0, 0, rs - chr + 2]]);
//    pts = concat(pb, pc, ptsm, ptst);
/*    
    for (i = [0: len(ptst) - 1]) {
        translate(ptst[i] + [0, 0, 0.5]) color("red") cylinder(h = 1, d = 0.5, $fn = 18);
    }
/**/

//    #translate([0, 0, -chr]) sphere(rs, $fn = 120);

    echo(heightAtTop([0, 0], rs));

    // for each point of the previous layer find the closest of these points
    closestPoints = [ for (i = [0: len(lastLayer) - 1]) closestToPoint(ptst, lastLayer[i]) ];
    
    faces = concat (
        // Unterseite: erste n punkte
        [[ for (i = [0: n - 1]) i ]],

        // Seitenflächen und gerundete Kante: Vierergruppen über alle Layer - 1
        [
            for (layer = [0: layers])
                for (i = [layer * n: (layer + 1) * n - 1]) [ i, (i + 1) % n + layer * n, (i + 1) % n + (layer + 1) * n, i + n]
        ],
/*
        // Seitenflächen und gerundete Kante: Vierergruppen über alle Layer - 1
        [
            for (layer = [0: layers - 1])
                for (i = [layer * n: (layer + 1) * n - 1]) [ i, (i + 1) % n + layer * n, (i + 1) % n + (layer + 1) * n, i + n]
        ],
/**/
/*
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
        [[ for (i = [(layers + 2) * n - 1: -1: (layers + 1) * n]) i ]],

/*
        // Schicht mit Index layers, layers + 1. Schicht, zum Zentrum
        // (layers + 1) * n ist der Punkt im Zentrum
        [ for (i = [0: n - 1]) [(layers + 1) * n, i + layers * n, (i + 1) % n + layers * n]],
/**/
    );
 

 
    render() difference() {
        polyhedron(pts, faces, convexity = 10);
        
//        translate([0, 0, 40]) #sphere(30);
        
        translate([0, 0, -chr]) hollowSphere(rs + 20, rs, $fn = quality);
    }
}

module hollowSphere(outerRadius, innerRadius) {
    difference() {
        sphere(outerRadius);
        sphere(innerRadius);
    }
}

function heightAtTop(point, radiusTop) =
    sqrt(radiusTop^2 - norm([point.x, point.y])^2);

module test3() {
// kurvige oberkante des randes, folgt der Rundung der Oberseite
    rs = 50;
    
    re = 2;
    

    kb = knobPoints(ARMS, 40);
    
    // unterste Schicht
    pb = [
        for (i = [0: 1: len(kb) - 1])
        [kb[i].x, kb[i].y, 0]
    ];
    
    // obere Schicht
    pc = [
        for (i = [0: 1: len(kb) - 1])
            let (rx = sqrt(kb[i].x ^ 2 + kb[i].y ^ 2))
            let (hm = sqrt((rs - re) ^ 2 - (rx - re) ^ 2))

            [kb[i].x, kb[i].y, hm - 38]
    ];
    pts = concat(pb, pc, [[0, 0, 11]]);

    n = len(kb);
    
    faces = concat (
        // Unterseite: erste n punkte
        [[ for (i = [0: 1: n - 1]) i ]],
        // Seitenflächen: Vierergruppen
        [
            for (i = [0: 1: n - 1]) [ i, (i + 1) % n, (i + 1) % n + n, i + n]
        ],
        // Oberseite: letzte Schicht dreiecke zum zentrum
        [ for (i = [0: 1: n - 1]) [2 * n, i + n, (i + 1) % n + n] ],
    );
    
        polyhedron(pts, faces);
}


module test2() {
    // Test Aufbau in Schichten
    // funktioniert nur mit Polarwinkel in knobPoints(), nicht mit
    // äquidistanten Punkten entlang des Umfangs
    layers = 13;


    pts = [
        for (a = [0: 1: layers - 1])
            let (angle = 90 / (layers - 1) * a)
            let (kp = knobPoints(ARMS, 35 + 8 * cos(angle)))
            for (b = [0: 1: len(kp) - 1])

            [kp[b].x, kp[b].y, 4 * sin(angle)]
    ];

    n = 36;

    faces = concat (
        // Unterseite: erste n punkte
        [[ for (i = [0: 1: n - 1]) i ]],
        // Seitenflächen: Vierergruppen über alle Layer - 1
        [
            for (layer = [0: 1: layers - 2])
                for (i = [layer * n: 1: (layer + 1) * n - 1]) [ i, (i + 1) % n + layer * n, (i + 1) % n + (layer + 1) * n, i + n]
        ],
        // Oberseite: letzte n punkte reversed
        [[ for (i = [layers * n - 1: -1: (layers - 1) * n]) i ]],
    );

    polyhedron(pts, faces);
}

module test1_1() {
    sqx = knobPoints(ARMS, kd);

    isqx = closestToCenter(sqx);

    translate(sqx[isqx]) color("cyan") cylinder(h = 20, d = 0.5, $fn = 36);
    translate(sqx[0]) color("blue") cylinder(h = 20, d = 0.5, $fn = 36);

    polygon(sqx);

    // test: -4
    x = offsetPoly(sqx, -4);

    ix = closestToCenter(x);

    translate(x[ix]) color("cyan") cylinder(h = 20, d = 0.5, $fn = 36);
    translate(x[0]) color("blue") cylinder(h = 20, d = 0.5, $fn = 36);

    translate([0, 0, 5]) color("red") polygon(x);

//echo(x, len(x));

    m = polyEliminatedIntersections(x);

echo("len poly", len(m));

    translate([0, 0, 10]) color("green") polygon(m);


    translate([m[len(m) - 1].x, m[len(m) - 1].y, 0]) color("red") cylinder(h = 20, d = 0.1, $fn = 36);
}

module test1() {
    // einzelne Schichten von Polygonen, nicht verbunden

    pts = knobPoints(ARMS, 40);

//    linear_extrude(height = 10, scale = 0.8) polygon(pts);

/*    
    translate([0, 0, 5])
        offset(r = -2)
            polygon(pts);
/*
    
    projection(cut = false) translate([0, 0, 10]) linear_extrude(12) offset(r = -1) polygon(pts);
/**/
    for (angle = [0: 5: 89]) {
        translate ([0, 0, 2 * sin(angle)])
            linear_extrude(0.2)
                offset(r = -(2 - 2 * cos(angle)))
                    polygon(pts);
    }

/*
    for (angle = [0: 5: 89]) {
        translate ([0, 0, 10 + 5 * sin(angle)])
            linear_extrude(0.1)
                polygon(knobPoints(ARMS, 40 * cos(angle)));
    }
/**/
}



// generates points for the outher edge of the knob
// returns an array [ [x1, y1], [x2, y2] ... [xn, yn] ]
function knobPoints(arms, diameter) =

    let (rKnob = diameter / 2)

    // radius of the arm circles
    let (rK = PI * rKnob / ((ap + 1) * arms + PI))
    // radius of the notch circles
    let (rN = nr * rK)

    // radius of the circle to place the arms (rbk)
    let (rPosK = rKnob - rK)

    // angle between arm and notch (360 / ARMS / 2)
    let (alpha = 180 / arms)

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
    let (angleStep = 360 / arms)
    
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

    let (armSteps = round(quality / arms * armShare))
    
    let (armAngleStep = 2 * (180 - beta) / armSteps)
    
    let (notchSteps = quality / arms - armSteps)
    
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

/**/
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