

hurz = 20;
txt = "horst2";

cube([hurz, 10, 10]);

translate([0, -20, 0])
    linear_extrude(3)
        text(txt);