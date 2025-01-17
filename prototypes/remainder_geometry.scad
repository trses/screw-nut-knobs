
// intersection point of two line segments
// returns undef if the line segments don't intersect
function intersect(l1, l2) = 
    let (x1 = l1[0].x)
    let (y1 = l1[0].y)
    let (x2 = l1[1].x)
    let (y2 = l1[1].y)
    let (x3 = l2[0].x)
    let (y3 = l2[0].y)
    let (x4 = l2[1].x)
    let (y4 = l2[1].y)
    
    // apply Cramer's rule to the system of linear equations
    // s(x2 - x1) - t(x4 - x3) = x3 - x1
    // s(y2 - y1) - t(y4 - y3) = y3 - y1
    let (a = x2 - x1)
    let (b = y2 - y1)
    let (c = x4 - x3)
    let (d = y4 - y3)

    let (e = x3 - x1)
    let (f = y3 - y1)

    // determinants
    let (detA = a * d - b * c)
    let (detS = e * d - f * c)
    let (detT = a * f - b * e)

    let (s = detS / detA)
    // -detT: Cramer's rule expects positive terms but t is negative in the equations
    let (t = -detT / detA)

    // the line segments intersect if 0 <= s <= 1 AND 0 <= t <= 1
    // the intersection is at [x1, y1] + s * the directional vector of the first line
    s >= 0 && s <= 1 && t >= 0 && t <= 1
        ? [x1, y1] + (s * [a, b])
        : undef
;