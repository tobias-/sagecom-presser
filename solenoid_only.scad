/*
  Standalone solenoid reference + first cradle iteration.
  Purpose: keep the solenoid model isolated while iterating the cradle.

  Axis convention:
  - Z = plunger axis
  - Front/plunger side at Z = 0
  - Rear side at positive Z
*/

// ---------------------------------------------------------------------------
// User parameters
// ---------------------------------------------------------------------------

part_to_render = "assembly";  // solenoid | cradle | assembly | collision_check
show_solenoid_in_assembly = true; // temporary visibility toggle for assembly preview

// Main body (from provided measurements)
solenoid_w = 30;  // body length along plunger axis (Z)
solenoid_h = 19;  // body width (X)
solenoid_d = 16;  // body height (Y)

// Front plunger
solenoid_front_piston_d = 6;
solenoid_front_rest = 12;
solenoid_front_extended = 17;

// Rear spring/rod side
solenoid_rear_spring_d = 15;
solenoid_rear_rod_d = 5;      // visual approximation
solenoid_rear_rest = 19;
solenoid_rear_activated = 14;
solenoid_rear_spring_len = 12; // visual approximation

// Visual options
show_rest = true;
show_activated = true;
show_body_centerline = true;

// Cradle (rectangular U-channel around solenoid body only)
cradle_clearance = 0.20;      // snug fit target (no intersection)
cradle_wall = 2.4;            // side wall thickness
cradle_floor = 1.8;           // bottom thickness (U base)
cradle_len_extra_front = 0.5; // extends ahead of body front (z < 0)
cradle_len_extra_rear = 1.4;  // extends past body rear (z > solenoid_w)
cradle_opening_margin = 0.6;  // extra opening above cavity top for easy insertion
rail_y_trim = 1.0;            // shortens side rails in Y so solenoid sticks out slightly
front_plate_t = 2.0;          // end plate thickness on plunger side
plunger_hole_extra_d = 2.0;   // requested: hole is plunger_d + 2mm
rear_stop_t = 1.2;            // rear end-stop thickness (opposite plunger side)
rear_stop_gap = 0.2;          // gap from solenoid rear face to stop
rear_stop_hole_extra_d = 1.5; // rear hole = spring_d + extra
rear_stop_keep_fraction_y = 0.5; // keep only lower fraction of rear stop for insertion

$fn = 56;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function clampv(v, lo, hi) = min(max(v, lo), hi);

module rounded_box(size = [20, 20, 10], r = 1.5, center = true) {
    sx = size[0];
    sy = size[1];
    sz = size[2];
    rr = clampv(r, 0, min(sx, sy) / 2 - 0.01);

    translate(center ? [0, 0, 0] : [sx / 2, sy / 2, sz / 2])
        linear_extrude(height = sz, center = true)
            offset(r = rr)
                square([sx - 2 * rr, sy - 2 * rr], center = true);
}

// ---------------------------------------------------------------------------
// Solenoid model
// ---------------------------------------------------------------------------

module solenoid_body() {
    color([0.58, 0.60, 0.64, 1.0])
        translate([0, 0, solenoid_w / 2])
            rounded_box([solenoid_h, solenoid_d, solenoid_w], 1.3, center = true);
}

// Body envelope used for cradle fit and collision checking.
module solenoid_body_envelope(clearance = 0) {
    color([0.7, 0.7, 0.75, 0.25])
        translate([0, 0, solenoid_w / 2])
            rounded_box(
                [
                    solenoid_h + 2 * clearance,
                    solenoid_d + 2 * clearance,
                    solenoid_w
                ],
                1.3,
                center = true
            );
}

module solenoid_front_plunger_rest() {
    color([0.88, 0.88, 0.88, 1.0])
        translate([0, 0, -solenoid_front_rest])
            cylinder(h = solenoid_front_rest, d = solenoid_front_piston_d, center = false);
}

module solenoid_front_plunger_activated_marker() {
    ext_extra = max(0, solenoid_front_extended - solenoid_front_rest);
    if (ext_extra > 0.01) {
        color([0.95, 0.2, 0.2, 0.6])
            translate([0, 0, -solenoid_front_extended])
                cylinder(h = ext_extra, d = solenoid_front_piston_d + 0.8, center = false);
    }
}

module solenoid_rear_rest() {
    color([0.85, 0.85, 0.85, 1.0])
        translate([0, 0, solenoid_w])
            cylinder(h = solenoid_rear_rest, d = solenoid_rear_rod_d, center = false);

    color([0.55, 0.55, 0.58, 0.85])
        translate([0, 0, solenoid_w + 0.5])
            cylinder(h = min(solenoid_rear_spring_len, solenoid_rear_rest), d = solenoid_rear_spring_d, center = false);
}

module solenoid_rear_activated_marker() {
    delta = max(0, solenoid_rear_rest - solenoid_rear_activated);
    if (delta > 0.01) {
        color([0.95, 0.2, 0.2, 0.6])
            translate([0, 0, solenoid_w + solenoid_rear_activated])
                cylinder(h = delta, d = solenoid_rear_rod_d + 0.8, center = false);
    }
}

module solenoid_centerline() {
    color([0.15, 0.75, 0.95, 0.7])
        translate([0, 0, -solenoid_front_extended])
            cylinder(h = solenoid_front_extended + solenoid_w + solenoid_rear_rest, d = 0.8, center = false);
}

module solenoid() {
    solenoid_body();

    if (show_rest) {
        solenoid_front_plunger_rest();
        solenoid_rear_rest();
    }

    if (show_activated) {
        solenoid_front_plunger_activated_marker();
        solenoid_rear_activated_marker();
    }

    if (show_body_centerline)
        solenoid_centerline();
}

// ---------------------------------------------------------------------------
// U-shaped cradle
// ---------------------------------------------------------------------------

module solenoid_cradle_u() {
    // Solenoid body bounds in current coordinate system:
    // X = [-solenoid_h/2, +solenoid_h/2]
    // Y = [-solenoid_d/2, +solenoid_d/2]
    // Z = [0, solenoid_w]
    //
    // U-channel is open toward +Y for insertion.
    // This is intentionally built as 3 solids:
    // 1) bottom strip
    // 2) left side strip
    // 3) right side strip
    // This avoids accidental "almost closed" geometry.
    inner_x = solenoid_h + 2 * cradle_clearance;  // rectangular body fit (X)
    inner_y = solenoid_d + 2 * cradle_clearance;  // rectangular body fit (Y)

    z_min = -cradle_len_extra_front;
    z_max = solenoid_w + cradle_len_extra_rear;
    z_len = z_max - z_min;

    // Bottom of U
    bot_x = inner_x + 2 * cradle_wall;
    bot_y = cradle_floor;
    bot_y_center = -inner_y / 2 - bot_y / 2;

    // Sides of U (rise up to just past body top clearance)
    side_x = cradle_wall;
    side_y = max(0.1, inner_y + cradle_opening_margin - rail_y_trim);
    side_y_center = -inner_y / 2 + side_y / 2;
    left_x_center = -inner_x / 2 - side_x / 2;
    right_x_center = inner_x / 2 + side_x / 2;

    // Overall Y extents of current U profile, used by front plate.
    y_min = -inner_y / 2 - bot_y;
    y_max = -inner_y / 2 + side_y;  // keep plate flush with trimmed side-rail top
    plate_y = y_max - y_min;
    plate_y_center = (y_min + y_max) / 2;
    plunger_hole_d = solenoid_front_piston_d + plunger_hole_extra_d;
    rear_stop_hole_d = solenoid_rear_spring_d + rear_stop_hole_extra_d;

    // Place rear stop near z_max but keep requested gap from body rear when possible.
    rear_stop_z_front = min(solenoid_w + rear_stop_gap, z_max - rear_stop_t);
    rear_stop_z_center = rear_stop_z_front + rear_stop_t / 2;
    rear_keep_y = max(0.1, plate_y * rear_stop_keep_fraction_y);
    rear_keep_y_center = y_min + rear_keep_y / 2;

    color([0.20, 0.26, 0.34, 1.0])
        union() {
            // Bottom rail
            translate([0, bot_y_center, z_min + z_len / 2])
                cube([bot_x, bot_y, z_len], center = true);

            // Left rail
            translate([left_x_center, side_y_center, z_min + z_len / 2])
                cube([side_x, side_y, z_len], center = true);

            // Right rail
            translate([right_x_center, side_y_center, z_min + z_len / 2])
                cube([side_x, side_y, z_len], center = true);

            // Front plate on plunger side (outside body envelope), with plunger hole.
            difference() {
                translate([0, plate_y_center, z_min - front_plate_t / 2])
                    cube([bot_x, plate_y, front_plate_t], center = true);

                translate([0, 0, z_min - front_plate_t / 2])
                    cylinder(h = front_plate_t + 0.4, d = plunger_hole_d, center = true);
            }

            // Rear stop plate (opposite end from plunger plate) to resist +Z push-out.
            if (rear_stop_t > 0.01) {
                difference() {
                    // Keep only lower Y-half (or configured fraction) for easier insertion.
                    translate([0, rear_keep_y_center, rear_stop_z_center])
                        cube([bot_x, rear_keep_y, rear_stop_t], center = true);

                    // Keep rear spring/rod area clear.
                    translate([0, 0, rear_stop_z_center])
                        cylinder(h = rear_stop_t + 0.4, d = rear_stop_hole_d, center = true);
                }
            }
        }
}

module cradle_collision_check() {
    // If this renders anything red, there is intersection to fix.
    color([1, 0, 0, 1])
        intersection() {
            solenoid_cradle_u();
            solenoid_body_envelope(0);
        }
}

module assembly_preview() {
    if (show_solenoid_in_assembly)
        solenoid();
    solenoid_cradle_u();
}

// ---------------------------------------------------------------------------
// Render selector
// ---------------------------------------------------------------------------

if (part_to_render == "solenoid")
    solenoid();
else if (part_to_render == "cradle")
    solenoid_cradle_u();
else if (part_to_render == "assembly")
    assembly_preview();
else if (part_to_render == "collision_check")
    cradle_collision_check();
