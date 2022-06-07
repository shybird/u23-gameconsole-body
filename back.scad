/*************************************************************************
 * Hülle für die u23-Spielekonsole.                                      *
 * Rückseite.                                                            *
 *                                                                       *
 * Author: Shy                                                           *
 * License: CC0                                                          *
 *************************************************************************/

 include <colors.scad>;

/* Höhe wichtiger Bauteile:
 *
 * NRF-Modul:
 * H: ~ 15 mm
 *
 * USB Port:
 * GCT USB4105-GF-A
 * H: 3.31 mm
 * B: 8.94 mm / 9.58 mm
 * L: 7.53 mm
 *
 * Klinkennuchse:
 * CUI SJ1-3523N
 * H: 6 mm
 * B: 12 mm
 * L: 14 mm
 *
 * RJ-45 Buchse:
 * RJMG1BD3B8K1ANR
 * H: 13.35 mm
 * B: 15.75 mm
 * L: 21.72 mm
 *
 * Vibrationsmotor:
 * Jinlong Z4KC1B1051202
 * H: 4.5 mm
 * B: 4.6 mm
 * L: 15.6 mm
 *
 * CF-Kartenadapter:
 * Hirose DM3AT-SF-PEJM5
 * H: 1.6 mm
 */

/* Default slim (Schrauben: M3, 16mm).
 *
 * space = 8;
 * border_height = 4;
 * nut_sink = 6;
 * side_recess = 0;
 *
 *
 * Default full (Schrauben: M3, 25mm).
 *
 * space = 15;
 * border_height = 8;
 * nut_sink = 4;
 * side_recess = 4;
 */

// Stützstrukturen.
support = false;

// Abgerundete Kanten (aufwendig).
rounded_corners = true;

// Dicke der Decke.
thickness = 1;

// Höhe des Innenraumes.
space = 8;

// Höhe des Randes. (Empfohlen: space/2.)
border_height = 4;

// Höhe der Verstrebungen.
struts = 2;

// Dicke der Aufhängungen an der Vorderkante.
loop_thickness = 3.5;

// Durchmesser der Bohrungen.
drill = 3.4;

// Durchmesser der Bohrschäfte.
drill_shaft = 7.4;

// Wird ein Gewindeeinsatz verwendet?
threaded_insert = false;

// Tiefe der Versenkung für die Mutter.
nut_sink = 6.0;

// Schlüsselweite der Mutter (M3 = 5.5 + Spiel).
wrench_size = 5.8;

// Durchmesser der Mutter von Kante zu Kante.
nut_size = wrench_size * 2 / sqrt(3);

// Position der Bohrungen.
drill_pos = [
    [10, 10],
    [10, 90],
    [140, 10],
    [140, 90],
];


// Platziere Reflektionsflächen unter den LEDs.
led_reflectors = false;

// Aussparungen über den Befestigungslöchern an den Seiten.
side_recess = 0;

// Füge Strukturen zur Stützung der Buttons auf der Vorderseite hinzu.
button_support = true;

// Füge Strukturen zur Stützung der Analog Sticks hinzu.
stick_support = true;

// Höhe, die der USB-Port benötigt.
limit_usb = 3.4;

// Höhe, die die Klinkenbuchse benötigt.
limit_audio_jack = 6.5;

// Soll ein nRF24-Modul verbaut werden?
nrf_module = false;

// Höhe, die das nRF24-Modul benötigt.
limit_nrf = 15;

// Höhe, die der Vibrationsmotor benötigt.
limit_vib = 7.5;


/*************************************************************************
 * Überprüfe Parameter auf Fehler.                                       *
 *************************************************************************/

// Achte auf die Höhe ausgewählter Bauteile.
if ((space - border_height) < limit_usb) {
    if ($preview) {
        // Zeige den Platz, den der USB-Port braucht.
        color(color_warning)
        translate([40, 92.35, space + thickness - limit_usb])
            cube([9, 8, limit_usb]);
    } else {
        assert((space - border_height) >= limit_usb,
            "USB-Port hat zu wenig Platz!");
    }
}

if (nrf_module && (space < limit_nrf)) {
    if ($preview) {
        // Zeige den Platz, den das nRF24-Modul braucht.
        color(color_warning)
        translate([101.25, 81.75, thickness])
            cube([29.5, 15.75, limit_nrf]);
    } else {
        assert(space >= limit_nrf,
            "nRF24-Modul hat zu wenig Platz!");
    }
}


/*************************************************************************
 * Einzelteile                                                           *
 *************************************************************************/

// Reflektionsflächen für die LEDs.
module led_reflector() {
    h = min(border_height + 2.5, space - 2.5);
    l = 12;
    w = 4;
    $fn = 24;

    // Sockel
    translate([-w/2, -l/2, 0])
        cube([w, l, struts]);

    hull() {
        translate([0, w/2 - l/2, 0]) {
            // Basis.
            cylinder(r=w/2, h=1);
            // Kuppelform.
            translate([0, 0, h - 3.5])
                intersection() {
                    sphere(r=w/2);
                    translate([-w/2, -w/2, 0])
                        cube([w, w, w]);
                }
            // Spitze.
            translate([0.5 + w/4, 0.5 + w/4, h - 0.25])
                sphere(0.5);
        }
        translate([0, l/2 - w/2, 0]) {
            // Basis.
            cylinder(r=w/2, h=1);
            // Kuppelform.
            translate([0, 0, h - 3.5])
                intersection() {
                    sphere(r=w/2);
                    translate([-w/2, -w/2, 0])
                        cube([w, w, w]);
                }
            // Spitze.
            translate([0.5 + w/4, 0.5 + w/4, h - 0.25])
                sphere(0.5);
        }
    }
}

// Schaft für die Schrauben.
module screw_shaft() {
    translate([0, 0, thickness])
        cylinder(h = space, r = drill_shaft/2, $fn=32);
    // Verdickung, um die Versenkung zu kompensieren.
    if(nut_sink > 0 && !threaded_insert) {
        translate([0, 0, thickness])
            cylinder(h = nut_sink, r = (nut_size + drill_shaft - drill)/2, $fn=32);
        intersection() {
            translate([0, 0, thickness + nut_sink])
                cylinder((nut_size + drill_shaft - drill)/2, (nut_size + drill_shaft - drill)/2, 0, $fn=32);
            // Begrenzt die Höhe.
            cylinder(r = (nut_size + drill_shaft - drill)/2, h = thickness + space, $fn=32);
        }
    }
}

// Bohrung für die Schrauben.
module screw_drill() {
    cylinder(h=space + thickness, r=drill/2, $fn=24);
    // Versenkung für die Mutter.
    if(nut_sink > 0 && !threaded_insert) {
        cylinder(h=nut_sink, r=nut_size/2, $fn=6);
    }
}

// Stützstrukturen.
module support(strength) {

    translate([-strength/2, -drill/2, 0])
        cube([strength, drill, nut_sink]);

    $fn = 6;
    difference() {
        cylinder(h=nut_sink, r=drill/2 + strength);
        cylinder(h=nut_sink, r=drill/2);
    }
}


// Ausschnittobjekt mit zweifach gerundeten Ecken.
// depth = Tiefe
// widht = Weite
// h1 = Höhe links oben
// h2 = Höhe rechts oben
// bevel = Größe der Rungungen
module cutout(depth=4, width=8, h1=2, h2=2, bevel=1) {

    // Addiere 0.01 um im Vorschaumodus Artefakte zu reduzieren.
    height = $preview ? max(h1, h2) + 0.01 : max(h1, h2);
    assert (width >= bevel * 2);
    $fn = 24;

    rotate([90, 0, 0]) {
        hull() {
            translate([0, max(height * 0.75, bevel), 0])
                cube([width, height/2, depth], center=true);

            translate([-width/2 + bevel, bevel, 0])
                cylinder(h=depth, r=bevel, center=true);

            translate([width/2 - bevel, bevel, 0])
                cylinder(h=depth, r=bevel, center=true);
        }

        // Zeichne Rundung nach links außen, falls die Höhe ausreicht.
        if (h1 >= bevel * 2) {
            translate([-width/2 - bevel, h1 - bevel, 0])
                // Linke Kante.
                difference() {
                    translate([0, 0, -depth/2])
                        cube([bevel, bevel, depth]);
                    cylinder(h=depth, r=bevel, center=true);
                }
        }

        // Zeichne Rundung nach rechts außen, falls die Höhe ausreicht.
        if (h2 >= bevel * 2) {
        translate([width/2 + bevel, h2 - bevel, 0])
            difference() {
                translate([-bevel, 0, -depth/2])
                    cube([bevel, bevel, depth]);
                cylinder(h=depth, r=bevel, center=true);
            }
        }
    }
}

// Aussparungen am Rand der Konsole.
module border_cutouts() {
    // Aussparung an der Klinke-Buchse.
    if (space - border_height < limit_audio_jack) {
        diff = limit_audio_jack - (space - border_height);

        translate([63, 91, border_height - diff])
            cutout(depth=20, width=14, h1=diff, h2=diff);
    }

    // Aussparung am Vibrationsmotor.
    if (space - border_height < limit_vib) {
        diff = limit_vib - (space - border_height);

        // Größe und Position durch Versuch.
        translate([119, 2 - 0.1 + 15.6/2, border_height - diff])
            cutout(depth=36, width=4.6 + 3.4, h1=diff, h2=diff);
    }

    // Aussparungen am Rand neben den seitlichen Befestigungslöchern.
    if (side_recess > 0) {
        // Die Aussparungen sollten nicht niedriger sein als die Verstrebungen.
        recess = min(side_recess, border_height - struts);

        // Aussparung auf der linken Seite.
        translate([5, 67, border_height - recess])
            rotate([0, 0, 90])
            cutout(
                depth=4,
                width=20,
                bevel=recess / 2,
                h1=recess,
                h2=recess);

        // Aussparung auf der rechten Seite.
        translate([150 - 5, 67, border_height - recess])
            rotate([0, 0, 90])
            cutout(
                depth=4,
                width=20,
                bevel=recess / 2,
                h1=recess,
                h2=recess);

        // Bei einer effektiven Höhe der Aussparungen > 2 schrägen wir eine
        // Seite ab.
        if (recess > 2) {

            multmatrix([
                    [1, 0, 0, 0],
                    [0, 1, -1, border_height - recess ],
                    [0, 0, 1, 0]
                ]) {

                // Linke Seite.
                translate([5, 67, border_height - recess])
                    rotate([0, 0, 90])
                    cutout(
                        depth=4,
                        width=20,
                        bevel=recess / 2,
                        h1=recess,
                        h2=recess);

                // Rechte Seite.
                translate([150 - 5, 67, border_height - recess])
                    rotate([0, 0, 90])
                    cutout(
                        depth=4,
                        width=20,
                        bevel=recess / 2,
                        h1=recess,
                        h2=recess);
            }
        }
    }
}

// Die äußeren Teile: Front und Ränder.
module outer() {
    // Decke.
    color(color_top)
    linear_extrude(height=thickness) {
        import("./svg/back top.svg");
    }

    // Rand.
    translate([0, 0, thickness]) {
        // Schneide Aussparungen aus dem Rand.
        difference() {
            union() {
                // Oberer Rand.
                color(color_border1)
                linear_extrude(height = border_height) {
                    import("./svg/back borders.svg");
                }
                // Unterer Rand.
                color(color_border2)
                translate([0, 0, border_height]) {
                    linear_extrude(height=space-border_height) {
                        import("./svg/back borders lower.svg");
                    }
                }
            }

            render() border_cutouts();
        }
    }

    // Verstrebungen.
    color(color_struts)
    translate([0, 0, thickness]) {
        linear_extrude(height=struts) {
            import("./svg/back struts.svg");
        }
    }

    // Aufhängungen.
    color(color_special)
    translate([0, 0, 0]) {
        linear_extrude(height=max(loop_thickness, thickness)) {
            import("./svg/back loops.svg");
        }
    }
}


/*************************************************************************
 * Die Hülle.                                                            *
 *************************************************************************/

module body_back() {
    if (rounded_corners) {
        intersection() {
            union () {
                outer();
            }

            color(color_top)
            minkowski() {
                linear_extrude(height=1) {
                    import("./svg/back hull.svg");
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

    // Stützen für die Buttons.
    if (button_support) {
        color(color_struts)
        translate([0, 0, thickness]) {
            linear_extrude(height=struts) {
                import("./svg/back pillars struts.svg");
            }
        }

        color(color_special)
        translate([0, 0, thickness]) {
            linear_extrude(height=space) {
                import("./svg/back pillars.svg");
            }
        }
    }

    // Stützen für die Analog sticks.
    if (stick_support) {
        color(color_struts)
        translate([0, 0, thickness]) {
            linear_extrude(height=struts) {
                import("./svg/back sticks struts.svg");
            }
        }

        color(color_special)
        translate([0, 0, thickness]) {
            linear_extrude(height=space - 2) {
                import("./svg/back sticks pillars.svg");
            }
        }

        color(color_special)
        translate([0, 0, thickness + space - 2]) {
            linear_extrude(height=2) {
                import("./svg/back sticks pillars top.svg");
            }
        }
    }

    // Schäfte für die Bohrungen.
    color(color_drills)
    for (i = [0:3]) {
        translate([drill_pos[i][0], drill_pos[i][1], 0])
            screw_shaft();
    }

    // LED-Reflektoren.
    color(color_special)
    if (led_reflectors) {
        translate([9, 84, thickness])
            led_reflector();
        translate([141, 84, thickness])
        mirror([1, 0, 0])
            led_reflector();
    }
}

// Platzierung der Bohrungen.
difference() {
    body_back();
    union() {
        // Bei einem Gewindeeinsatz wird die Decke nicht durchbohrt.
        floor = threaded_insert ? thickness : 0;
        for (i = [0:3]) {
            translate([drill_pos[i][0], drill_pos[i][1], floor])
                screw_drill();
        }
    }
}

if (support && !threaded_insert) {
    color(color_special)
    for (i = [0:3]) {
        translate([drill_pos[i][0], drill_pos[i][1], 0])
            support(0.75);
    }
}

