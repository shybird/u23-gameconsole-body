/*************************************************************************
 * Hülle für die u23-Spielekonsole.                                      *
 * Buttons.                                                              *
 *                                                                       *
 * Autor: Shy                                                            *
 * License: CC0                                                          *
 *************************************************************************/

/* Maße relevanter Bauteile:
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
 */

include <front.scad>;
include <colors.scad>;

// Überstand der Buttons über die Hülle.
protrusion = 2;

// Tiefe des Zeichnungen auf den Buttons.
carving = 0.25;

// Buttons haben runde Kanten. (Rechenaufwendiger.)
beveled = true;

// Größe der Rundung.
bevel_size = 1;

// Spiel zwischen den Schulterbuttons und der Hülle.
button_trigger_clearance = 0.25;

// Dicke der Schiene und Widerhaken der Schulterbuttons.
// (5.8 mm - 3 mm) / 2 + 3 mm nach Datenblatt.
button_trigger_rail = space - 4.4 - button_trigger_clearance;

// Gesamthöhe der Systembuttons.
system_height = space - button_system_size - button_clearance + thickness + protrusion;

// Gesamthöhe der Aktionsbuttons.
action_height = space - button_action_size - button_clearance + thickness + protrusion;


/**************************************************************************
 * Einzelteile.                                                           *
 *************************************************************************/

// Aktions-Buttons.
module action_buttons() {
    // Basis.
    linear_extrude(height = button_action_base) {
        import("./svg/buttons action base.svg");
    }

    difference() {
        // Hauptteil.
        linear_extrude(height = action_height) {
            import("./svg/buttons action main.svg");
        }
        // Zeichnung.
        translate([0, 0, action_height - carving])
        linear_extrude(height = carving) {
            import("./svg/buttons action carvings.svg");
        }

    }
}

// Schulter-Buttons.
module trigger_button() {
    // Basis.
    linear_extrude(height = button_trigger_rail) {
        import("./svg/buttons trigger lower.svg");
    }

    linear_extrude(height = space - button_trigger_clearance) {
        import("./svg/buttons trigger upper.svg");
    }
}

// System-Buttons.
module system_button() {
    // Höhe, Basis, Breite.
    h = system_height;
    b = button_system_base;
    w = 3;

    polyhedron(points = [
        // Unterseite
        [1, 0, 0],
        [9, 0, 0],
        [10, b, 0],
        [8, b, 0],
        [8, h, 0],
        [2, h, 0],
        [2, b, 0],
        [0, b, 0],
        // Oberseite
        [1, 0, w],
        [9, 0, w],
        [10, b, w],
        [8, b, w],
        [8, h, w],
        [2, h, w],
        [2, b, w],
        [0, b, w]
    ], faces = [
        [0, 1, 2, 3, 4, 5, 6, 7],
        [0, 8, 9, 1],
        [1, 9, 10, 2],
        [2, 10, 11, 3],
        [3, 11, 12, 4],
        [4, 12, 13, 5],
        [5, 13, 14, 6],
        [6, 14, 15, 7],
        [7, 15, 8, 0],
        [15, 14, 13, 12, 11, 10, 9, 8]
    ]);
}

// Abgerundeter Button. Nur der Hauptteil.
module beveled_button (r=1, h=1, b=1) {
    union() {
        cylinder(h=h - b, r=r, $fn=24);

        translate([0, 0, h-b*2])
        minkowski() {
            cylinder(h=b, r=r-b, $fn=24);
            sphere(r=b, $fn=24);
        }
    }
}

// Kreuz-Button.
module cross (l=12, w=4, h=2) {
    translate([0, 0, h/2])
    union() {
        cube([l, w, h], center=true);
        rotate([0, 0, 90])
            cube([l, w, h], center=true);
    }
}

// Kreuz-Button mit abgerundeten Kanten.
module beveled_cross (l=12, w=4, h=2, b=1) {
    union() {
        minkowski() {
            cross(l-b*2, w-b*2, h-b*2);
            cylinder(r=b, h=b, $fn=12);
        }

        translate([0, 0, h-b*2])
        minkowski() {
            cross(l-b*2, w-b*2, b);
            sphere(r=b, $fn=12);
        }
    }
}

// Aktionsbuttons mit abgerundeten Kanten.
module beveled_action(bevel=1) {
    // Basis.
    linear_extrude(height = button_action_base) {
        import("./svg/buttons action base.svg");
    }

    difference() {
        union() {
            // Plaztiere das Kreuz auf der Basis.
            translate([12, 12, 0])
            beveled_cross(l=24, w=8, h=action_height, b=bevel);

            // Platziere vier Buttons auf der Basis.
            for (pos = [[31, 7], [41, 17], [53, 7], [63, 17]]) {
                translate([pos.x, pos.y, 0])
                beveled_button(r=5, h=action_height, b=bevel);
            }
        }
        // Die Zeichnungen auf der Oberseite.
        translate([0, 0, action_height - carving])
        linear_extrude(height = carving) {
            import("./svg/buttons action carvings.svg");
        }
    }

}


/**************************************************************************
 * Anordnung.                                                             *
 *************************************************************************/

// Render nur die Buttons, nicht die eingebundene Datei <front.scad>.
!if(true) {
    // Aktions-Buttons.
    translate([0, 23, 0])
    if(beveled) {
        color(color_buttons)
            beveled_action(bevel_size);
    } else {
        color(color_buttons)
            action_buttons();
    }

    // Schulterbuttons.
    color(color_buttons)
    translate([52, 21, 0])
    rotate([0, 0, 180])
        trigger_button();

    color(color_buttons)
    translate([0, 21, 0])
    rotate([0, 0, 180])
    mirror([1, 0, 0])
        trigger_button();

    // Drucke drei Systembuttons nebeneinander.
    color(color_buttons)
    for (i = [0, 11, 22]) {
        translate([10 + i, 8, 0])
            system_button();
    }

    // Verbinde die dreit Buttons mit einem dünnen Steg.
    color(color_buttons)
    translate([12 + 1, 8 + button_system_base / 2, 0])
        cube([30, 1, 3]);
};

