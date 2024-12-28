

ARMS = 3;

// knobDiameter
kd = 40;


/*
minkowski() {
    sphere(2, $fn = 36);

    difference() {
        translate([0, 0, -30]) sphere(d = 99, $fn = 120);

        difference () {
            translate([0, 0, -35]) cube(110, center = true);
            
            linear_extrude(20) polygon(knobPoints(6, 40));
        }
    }
}
/**/

/*
sqx = knobPoints(ARMS, kd);

// https://stackoverflow.com/questions/4876065/is-there-an-easy-and-fast-way-of-checking-if-a-polygon-is-self-intersecting
// https://www.webcitation.org/6ahkPQIsN
// https://github.com/rowanwins/shamos-hoey

polygon(sqx);

x = offsetPoly(sqx, -1.73);

translate([0, 0, -5]) color("red") polygon(x);
*/
//echo(x);

difference() {
    test4();
//    cube(30);
}

// Linie entlang des Kugelradius


module test4() {
    // Aufbau in Schichten
    // erste Schicht liegt in der xy Ebene
    // zweite Schicht mit variablen z Werten
    // weitere Schichten: z-Wert der zweiten Schicht + sin (edgeAngle)
    
    // Radius der gerundeten Oberfläche
    rs = 50;
    
    // Radius der abgerundeten Kante
    re = 2;

    kb = knobPoints(ARMS, kd);

    n = len(kb);

    
    // unterste Schicht
    pb = [
        for (i = [0: 1: len(kb) - 1])
        [kb[i].x, kb[i].y, 0]
    ];
    
    // zweite Schicht
    pc = [
        for (i = [0: 1: len(kb) - 1])
            // radius des griffs an der aktuellen stelle
            let (rx = sqrt(kb[i].x ^ 2 + kb[i].y ^ 2))
            // höhe des Mittelpunkts des Kreises der Rundung an der aktuellen stelle
            let (hm = sqrt((rs - re) ^ 2 - (rx - re) ^ 2))

            [kb[i].x, kb[i].y, hm - 38]
    ];

    // Anzahl Schichten Rundung
    layers = 5;

    // Schichten der Rundung
    // Beginn bei 1 weil Schicht 0 der Rundung bereits in pc ist
    ptsm = [
        for (a = [1: 1: layers - 1])
            let (angle = 90 / (layers - 1) * a)
            let (kpo = knobPoints(ARMS, kd - (re * 2) + re * 2 * cos(angle)))
            let (kp = offsetPoly(knobPoints(ARMS, kd), -re+re * cos(angle)))
            for (b = [0: 1: len(kp) - 1])

            [kp[b].x, kp[b].y, pc[b].z + re * sin(angle)]
    ];

    pts = concat(pb, pc, ptsm, [[0, 0, rs - 38]]);

    faces = concat (
        // Unterseite: erste n punkte
        [[ for (i = [0: 1: n - 1]) i ]],
        // Seitenflächen: Vierergruppen über alle Layer - 1
        [
            for (layer = [0: 1: layers - 1])
                for (i = [layer * n: 1: (layer + 1) * n - 1]) [ i, (i + 1) % n + layer * n, (i + 1) % n + (layer + 1) * n, i + n]
        ],
        // Schicht mit Index layers, layers + 1. Schicht, zum Zentrum
        [ for (i = [0: 1: n - 1]) [(layers + 1) * n, i + layers * n, (i + 1) % n + layers * n]],
    );

    polyhedron(pts, faces);    
}


module test3() {

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


module test1() {

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
function knobPoints(arms, diameter) =

    let (rKnob = diameter / 2)
    // armPitch
    let (ap = 2)
    // notchRatio
    let (nr = 4)

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
   
    let (quality = 360) // steps along outline
   
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
            
            [armX + rK * cos(phi2), armY + rK * sin(phi2)]],
    
        // über die Notch
        [for (i = [0: 1: notchSteps - 1])
            // center liegt außen, laufen im Uhrzeigersinn
            let (phi2 = notchStartAngle - i * notchAngleStep)
            
            [notchX + rN * cos(phi2), notchY + rN * sin(phi2)]]
    )
];

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
    p + l * bis
];

function degToRad(degrees) = degrees * PI / 180;

function radToDeg(radians) = radians * 180 / PI;
