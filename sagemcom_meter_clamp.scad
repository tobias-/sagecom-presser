/*
  Sagemcom-style water meter accessory mount
  Stage 1: minimal button-area frame

  This is intentionally much simpler than the earlier faceplate:
  - a rectangular lower-front frame spanning the full meter width
  - a round button access hole
  - no strap tabs yet
  - no camera mount yet
  - no solenoid mount yet

  The goal of this part is only to validate:
  - how much front-area coverage is acceptable
  - the front shape only, before retention details are added
  - the actual button location relative to the visible housing
*/

// ---------------------------------------------------------------------------
// User-editable parameters
// ---------------------------------------------------------------------------

part_to_render = "preview";   // preview, button_frame_base
show_reference_housing = true;
show_centerlines = true;

// Known housing front footprint
housing_w = 58;
housing_h = 92;
housing_corner_r = 6;   // estimated

// Button location on the front face
// Measure `button_x_from_left` on the real meter if possible.
// `mirror_button_x` exists because the workspace photo is rotated and not
// trustworthy enough for left/right handedness.
button_x_from_left = 18;
mirror_button_x = true;
button_y = 16;          // from the nearest short edge
button_d = 12;          // estimated

// Display opening on the front face
// Estimated from the meter photo. Update once measured.
display_x_from_left = housing_w / 2;  // keep LCD centered on housing X
display_y_from_bottom = 58;
display_y_offset = 0;                 // fine vertical adjustment if needed
display_w = 40;
display_h = 18;
display_corner_r = 2;
display_bezel_margin = 1.6;
display_bezel_t = 1.1;
display_active_inset = 2.0;
display_active_t = 0.5;

// Lower frame that follows housing shape and stops below the display
frame_t = 4.5;
frame_wall = 6;
frame_to_display_gap = 3;
bottom_edge_margin = 2;
button_relief_d = 18;
centerline_w = 0.8;
housing_ref_t = frame_t * 0.5;
housing_ref_touch_overlap = 0.04;  // tiny overlap so reference and frame "just touch" in Z

// Side extensions for extra zip-tieability above the display.
side_upright_enable = true;
side_upright_w = frame_wall;       // match original frame border width
side_upright_above_display = 8;    // how far rails extend above display top
side_upright_display_clearance = 1.2; // keep rails clear of LCD bezel envelope

$fn = 48;

// ---------------------------------------------------------------------------
// Derived values
// ---------------------------------------------------------------------------

button_pos = [
    -housing_w / 2 + (mirror_button_x ? (housing_w - button_x_from_left) : button_x_from_left),
    -housing_h / 2 + button_y
];

display_pos = [
    -housing_w / 2 + display_x_from_left,
    -housing_h / 2 + display_y_from_bottom + display_y_offset
];

display_bottom_y = display_pos[1] - display_h / 2;
display_top_y = display_pos[1] + display_h / 2;
frame_top_y = display_bottom_y - frame_to_display_gap;
frame_bottom_y = -housing_h / 2 + bottom_edge_margin;
frame_mid_y = (frame_bottom_y + frame_top_y) / 2;
side_upright_top_y = min(housing_h / 2 - 1, display_top_y + side_upright_above_display);
display_bezel_half_w = (display_w + 2 * display_bezel_margin) / 2;
side_upright_x_abs = min(
    housing_w / 2 - side_upright_w / 2 - 0.2,
    display_bezel_half_w + side_upright_display_clearance + side_upright_w / 2
);
housing_ref_top_z = housing_ref_touch_overlap;
housing_ref_center_z = housing_ref_top_z - housing_ref_t / 2;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function clampv(v, lo, hi) = min(max(v, lo), hi);

module rounded_box(size = [20, 20, 5], r = 2, center = true) {
    sx = size[0];
    sy = size[1];
    sz = size[2];
    rr = clampv(r, 0, min(sx, sy) / 2 - 0.01);

    // Keep the rounded box truly centered in X/Y when center=true.
    // Using a centered 2D profile avoids an implicit -r shift from offset().
    translate(center ? [0, 0, 0] : [sx / 2, sy / 2, sz / 2])
        linear_extrude(height = sz, center = true)
            offset(r = rr)
                square([sx - 2 * rr, sy - 2 * rr], center = true);
}

module housing_reference() {
    color([0.95, 0.95, 0.95, 0.35])
        translate([0, 0, housing_ref_center_z])
            rounded_box([housing_w, housing_h, housing_ref_t], housing_corner_r, center = true);

    // LCD reference as bezel + active screen area.
    color([0.08, 0.08, 0.08, 0.9])
        translate([display_pos[0], display_pos[1], housing_ref_top_z + display_bezel_t / 2 + 0.05])
            rounded_box(
                [display_w + 2 * display_bezel_margin, display_h + 2 * display_bezel_margin, display_bezel_t],
                display_corner_r + 0.8,
                center = true
            );

    color([0.18, 0.42, 0.18, 0.9])
        translate([display_pos[0], display_pos[1], housing_ref_top_z + display_bezel_t + display_active_t / 2 + 0.05])
            rounded_box(
                [display_w - 2 * display_active_inset, display_h - 2 * display_active_inset, display_active_t],
                max(0.6, display_corner_r - 0.6),
                center = true
            );

    color([0.15, 0.35, 0.95, 0.85])
        translate([button_pos[0], button_pos[1], housing_ref_top_z + 0.1])
            cylinder(h = 0.8, d = button_d);
}

module housing_centerlines() {
    // X-centerline of housing reference (this is the relevant centering check).
    color([0.9, 0.2, 0.2, 0.8])
        translate([0, 0, housing_ref_top_z + 0.3])
            cube([centerline_w, housing_h, 0.6], center = true);
}

module frame_centerlines() {
    // X-centerline of the lower frame band. Should overlap housing X-centerline.
    color([0.95, 0.05, 0.85, 0.85])
        translate([0, frame_mid_y, frame_t + 0.65])
            cube([centerline_w, frame_top_y - frame_bottom_y, 0.6], center = true);
}

module housing_outline_2d() {
    offset(r = housing_corner_r)
        square([housing_w - 2 * housing_corner_r, housing_h - 2 * housing_corner_r], center = true);
}

module lower_band_mask_2d() {
    translate([0, (frame_bottom_y + frame_top_y) / 2])
        square([housing_w + 8, frame_top_y - frame_bottom_y], center = true);
}

module side_upright_mask_2d() {
    rail_h = side_upright_top_y - frame_bottom_y;
    for (sx = [-1, 1]) {
        translate([
            sx * side_upright_x_abs,
            (frame_bottom_y + side_upright_top_y) / 2
        ])
            square([side_upright_w, rail_h], center = true);
    }
}

module outer_frame_region_2d() {
    intersection() {
        housing_outline_2d();
        union() {
            lower_band_mask_2d();
            if (side_upright_enable)
                side_upright_mask_2d();
        }
    }
}

// ---------------------------------------------------------------------------
// Stage 1 part
// ---------------------------------------------------------------------------

module button_frame_base() {
    linear_extrude(height = frame_t)
        difference() {
            outer_frame_region_2d();

            // True frame: inward offset creates uniform wall thickness.
            offset(delta = -frame_wall)
                outer_frame_region_2d();

            // Dedicated button opening through the frame.
            translate(button_pos)
                circle(d = button_relief_d);
        }
}

module preview() {
    if (show_reference_housing)
        housing_reference();

    color([0.95, 0.7, 0.1, 0.75])
        button_frame_base();

    if (show_centerlines) {
        if (show_reference_housing)
            housing_centerlines();
        frame_centerlines();
    }
}

// ---------------------------------------------------------------------------
// Render selector
// ---------------------------------------------------------------------------

if (part_to_render == "button_frame_base")
    button_frame_base();

if (part_to_render == "preview")
    preview();
