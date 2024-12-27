

ARMS = 5;

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
    
    echo (kb);
    
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
    layers = 2;

    // Schichten der Rundung
    // Beginn bei 1 weil Schicht 0 der Rundung bereits in pc ist
    ptsm = [
        for (a = [1: 1: layers - 1])
            let (angle = 90 / (layers - 1) * a)
            let (kp = knobPoints(ARMS, kd - (re * 2) + re * 2 * cos(angle)))
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
union() {
linear_extrude(10) polygon(knobPoints(ARMS, 40));

for (angle = [0: 5: 89]) {
    translate ([0, 0, 10 + 5 * sin(angle)])
        linear_extrude(0.1)
            polygon(knobPoints(ARMS, 40 * cos(angle)));
}
}
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
    
    
    let (arcArmMM = degToRad(2 * (180 - beta)) * rK)

    let (arcNotchMM = degToRad(2 * gamma) * rN)
    
    let (armShare = arcArmMM / (arcArmMM + arcNotchMM))

    let (armSteps = round(360 / arms * armShare))
    
    let (armAngleStep = 2 * (180 - beta) / armSteps)
    
    let (notchSteps = 360 / arms - armSteps)
    
    let (notchAngleStep = 2 * gamma / notchSteps)

    let (abc = echo(180 - beta, gamma, armAngleStep, notchAngleStep))

/**/

// über alle Arme
[for (phi = [0: angleStep: ARMS * angleStep - 1])
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
    )];
/*
[
for (phi = [0: 1: 359])
    let (arm = floor(phi / angleStep))
    let (phiTemp = phi - (arm * angleStep))
    // only half of an arm is uniquely defined, the rest can be determined
    // by rotation and mirroring
    let (phiNorm = phiTemp > angleStep / 2
            ? angleStep - phiTemp
            : phiTemp)
    let (rx = abs(phiNorm) < 1e-6
        ? rKnob
        : abs(phiNorm - angleStep / 2) < 1e-6
            ? rPosN - rN
            : phiNorm < alphaC
                ?
                let (gamma2 = asin(rPosK * sin(phiNorm) / rK))
                let (beta2 = 180 - phiNorm - gamma2)
                rK * sin(beta2) / sin(phiNorm)
                :
                let (delta = alpha - phiNorm)
                let (epsilon = 180 - asin(rPosN * sin(delta) / rN))
                let (rho = 180 - delta - epsilon)
                rN * sin(rho) / sin(delta)
    )

    [rx * cos(phi), rx * sin(phi)]
];
/**/

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


function degToRad(degrees) = degrees * PI / 180;

function radToDeg(radians) = radians * 180 / PI;
