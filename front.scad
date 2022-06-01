/*************************************************************************
 * Hülle für die u23-Spielekonsole.                                      *
 * Vorderseite.                                                          *
 *                                                                       *
 * Author: Shy                                                           *
 * License: CC0                                                          *
 *************************************************************************/

include <colors.scad>;

/* Höhe wichtiger Bauteile:
 *
 * Display:
 * Z320IT010
 * L: 54 mm
 * B: 77.4 mm
 * H: 2.4 mm
 * Davon LCD:
 * L: 48.6 mm
 * B: 64.8 mm, mit 3.35 mm Abstand zum rechten Rand
 *
 * Kurzhubtaster Pads:
 * PTS645SL50-2 LFS
 * H Taster: 5 mm
 * H Gehäuse: 3.45 mm
 * D Taster: 3.5 mm
 * 
 * Kurzhubtaster unten:
 * PTS645SK43SMTR92 LFS
 * H Taster: 4.3 mm
 * H Gehäuse: 4.3
 * D Taster: 3.5 mm
 * 
 * Schalter an der Schulter:
 * D2FS-FL-N-A
 * H: 5.8 mm
 * B: 12.8 mm
 *
 * Analog Stick:
 * Alps RKJXV1224005
 * H Gehäuse: 10.8 mm
 * H bis Gelenk: 12.46 mm
 * L: 21.3 mm
 * B: 17.8 mm
 * Der Kern ist ein Quadrat mit 13.15 mm Kantenlänge.
 * Anschlag 7 mm von der Platine.
 */

// Abgerundete Kanten (aufwendig).
rounded_corners = true;

// Dicke der Decke.
thickness = 1.0;

// Höhe des Innenraumes.
space = 7;

// Höhe des oberen Randes.
border_height = 4;

// Höhe der Verstrebungen.
struts = 2;

// Durchmesser der Bohrungen.
drill = 3.4;

// Durchmesser der Bohrschäfte.
drill_shaft = 7.4;

// Position der Bohrungen.
drill_pos = [
    [10, 20],
    [10, 100],
    [140, 20],
    [140, 100],
];

// Dicke der Basis der Aktionsbuttons.
button_action_base = 1;

// Dicke der Basis der Systembuttons.
button_system_base = 2;

// Tatsächliche Höhe der Taster unter den Aktionsbuttons.
button_action_size = 5;

// Tatsächliche Höhe der Taster unter den Systembuttons.
button_system_size = 4.3;

// Spiel der Buttons zwischen Taster und Decke.
button_clearance = 0.2;

// LEDs am unteren Rand.
led_bottom = true;

// Y-LED.
led_y = true;

// LED-Pegel.
led_gauge = true;

// Aussparungen für die Analog-Sticks.
analog_sticks = false;


/*************************************************************************
 * Überprüfe Parameter auf Fehler.                                       *
 *************************************************************************/

//assert(space >= trigger_switch_height + button_trigger_base,
//    "Die Höhe reicht nicht für die Schultertasten!");


/*************************************************************************
 * Einzelteile                                                           *
 *************************************************************************/

// Durchbrüche in der Front.
module top_cutouts() {
    // LEDs am unteren Rand.
    if (led_bottom) {
        linear_extrude(height=thickness) {
            import("./svg/front led bottom.svg");
        }
    }

    // LED-Pegel.
    if (led_gauge) {
        linear_extrude(height=thickness) {
            import("./svg/front led gauge.svg");
        }
    }

    // Y-LED.
    if (led_y) {
        linear_extrude(height=thickness) {
            import("./svg/front led y.svg");
        }
    }
}

// Schaft für die Schrauben.
module screw_shaft() {
    translate([0, 0, thickness])
        cylinder(h = space, r = drill_shaft/2, $fn=32);
}

// Platzsparendere Stützen für die Bohrungen am oberen Rand.
module screw_support(width, length) {
    translate([0, 0, thickness + (space / 2)])
        cube([width, length, space], center=true);
}

// Bohrung für die Schrauben.
module screw_drill() {
    cylinder(h=space + thickness, r=drill/2, $fn=24);
}

// Maske für Stellen, an denen der Rand nicht ganz auf der Platine aufliegen
// kann.
module border_pcb_cutouts() {
    // Vibrator.
    translate([28, 10 + 1, -1.5])
        cube([6, 1, 1.5]);

    // Klinkenbuchse.
    translate([77.5, 110 - 2, -1])
        cube([13.5, 1, 1]);
}

// Die äußeren Teile: Front und Ränder.
module outer() {
    // Decke.
    color(color_top)
    linear_extrude(height=thickness) {
        import("./svg/front top.svg");
    }

    // Oberer Rand.
    color(color_border1)
    translate([0, 0, thickness]) {
        linear_extrude(height = border_height) {
            import("./svg/front borders.svg");
        }
    }

    // Unterer Rand.
    color(color_border2)
    translate([0, 0, thickness + border_height]) {
        difference() {
            linear_extrude(height=space - border_height) {
                import("./svg/front borders lower.svg");
            }
            // Stellen, an denen der Rand nicht ganz auf der Platine aufliegen
            // kann.
            translate([0, 0, space - border_height])
                border_pcb_cutouts();
        }
    }

    // Verstrebungen.
    color(color_struts)
    translate([0, 0, thickness]) {
        linear_extrude(height=struts) {
            import("./svg/front struts.svg");
        }
    }

}

// Kleine Streben zwischen Decke und Rand.
module border_strut(width, length, height) {
    x = width/2;
    y = length/2;

    polyhedron(points = [
        [-x, -y, 0],
        [x, -y, 0],
        [x, y, 0],
        [-x, y, 0],
        [-x, y, height],
        [x, y, height]
    ], faces = [
        [0, 1, 2, 3],
        [1, 5, 2],
        [2, 5, 4, 3],
        [3, 4, 0],
        [0, 4, 5, 1]
    ]);

}


/*************************************************************************
 * Die Hülle.                                                            *
 *************************************************************************/

module casing_front() {
    difference() {
        if (rounded_corners) {
            intersection() {
                union () {
                    outer();
                }

            color(color_top)
                minkowski() {
                    linear_extrude(height=1) {
                        import("./svg/front hull.svg");
                    }
                    hull() {
                        $fn = $preview ? 4 : 16;
                        for (i = [1:5]) {
                            translate([0, 0, i - 1])
                            cylinder(r=sin(i * (90/5)) * 2, h=thickness + space);
                        }
                    }
                }
            }
        } else {
            outer();
        }

        if ($preview) {
            // Vergrößere das zu substrahierende Objekt, um Darstellungsfehler
            // in der Voransicht zu vermeiden.
            translate([0, 0, -0.1])
            resize([0, 0, thickness + 0.2])
                top_cutouts();
        } else {
            top_cutouts();
        }
    }

    // Zusätzliche Verstrebungen zwischen Decke und Rand.
    if (rounded_corners) {
        color(color_struts)
        for (pos = [
                // [x, y, rotation, länge]
                [49, 107.5, 0, 3],
                [57, 107.5, 0, 3],
                [65, 107.5, 0, 3],
                [73, 107.5, 0, 3],
                [80, 107.5, 0, 3],
                [87, 107.5, 0, 3],

                [147.5, 85, 270, 3],
                [148, 78.5, 270, 2],
                [148, 71.5, 270, 2],
                [147.5, 65, 270, 3],
                [147.5, 57, 270, 3],
                [148, 49, 270, 2],
                [148, 41, 270, 2],

                [109, 12.5, 180, 3],
                [94, 12.5, 180, 3],
                [56, 12.5, 180, 3],
                [41, 12.5, 180, 3],
                [26, 12.5, 180, 3],

                //[5, 40, 90, 2],
                [5, 44, 90, 2],
                [5, 50, 90, 2],
                [2.5, 66, 90, 3],
                [2.5, 84, 90, 3],
            ]) {
            translate([pos[0], pos[1], thickness])
                rotate([0, 0, pos[2]])
                border_strut(1.6, pos[3], pos[3]);
        }
    }

    // Halterungen für die Aktionsbuttons.
    // Begrenzung nach oben.
    color(color_buttons)
    translate([0, 0, thickness]) {
        linear_extrude(height = space - button_action_size - button_action_base - button_clearance) {
            import("./svg/front button action upper.svg");
        }
    }

    // Führung für die Aktionsbuttons.
    color(color_buttons)
    translate([0, 0, thickness]) {
        // Wir ziehen die Führungen zwei Millimeter tiefer, um auf der sicheren
        // Seite zu sein.
        linear_extrude(height = space - button_action_size + 2) {
            import("./svg/front button action lower.svg");
        }
    }

    // Halterungen für die Systembuttons.
    // Begrenzung nach oben.
    color(color_buttons)
    translate([0, 0, thickness]) {
        linear_extrude(height = space - button_system_size - button_system_base - button_clearance) {
            import("./svg/front button system upper.svg");
        }
    }

    // Führung für die Systembuttons.
    color(color_buttons)
    translate([0, 0, thickness]) {
        linear_extrude(height = space - button_system_size) {
            import("./svg/front button system lower.svg");
        }
    }

    // Schäfte für die Bohrungen.
    color(color_drills)
    for (i = [0:3]) {
        if (drill_pos[i].y > 50) {
            // Am oberen Rand brauchen wir andere Stützen, um Platz für die
            // Schultertasten zu machen.
            if (drill_pos[i].x > 75) {
                // Rechts oben.
                translate([drill_pos[i].x + (150 - drill_pos[i].x) / 2, drill_pos[i].y, 0])
                    // 2 mm kürzer, damit das Bauteil nicht am Rand übersteht.
                    screw_support(150 - drill_pos[i].x - 2, drill);
            } else {
                // Links oben.
                translate([drill_pos[i].x / 2, drill_pos[i].y, 0])
                    screw_support(drill_pos[i].x - 2, drill);
            }

        // Die normalen Bohrungen am unteren Rand.
        } else {
            translate([drill_pos[i].x, drill_pos[i].y, 0])
                screw_shaft();
        }
    }

    // Verstärkungen für die Analog-Sticks.
    if (analog_sticks) {
        color(color_struts)
        translate([0, 0, thickness]) {
            linear_extrude(height = struts) {
                import("./svg/front analog sticks struts.svg");
            }
        }
    }
}

// Plazierung der Bohrungen.
difference() {
    casing_front();
    union() {
        for (i = [0:3]) {
            translate([drill_pos[i][0], drill_pos[i][1], 0])
                screw_drill();
        }

        // Die Löcher für die Analog-Sticks.
        if (analog_sticks) {
            linear_extrude(height = space) {
                import("./svg/front analog sticks.svg");
            }
        }
    }
}

