/*
  Sagemcom button pusher rig (combined assembly)

  Uses:
  - sagemcom_meter_clamp.scad  (meter/frame reference)
  - solenoid_only.scad         (solenoid + cradle geometry)

  Goal:
  - Place the standalone solenoid cradle onto the meter frame scene
  - Align plunger axis to the blue button
*/

use <sagemcom_meter_clamp.scad>
use <solenoid_only.scad>

// ---------------------------------------------------------------------------
// Combined preview controls
// ---------------------------------------------------------------------------

part_to_render = "combined_preview"; // combined_preview | combined_printable | frame_only | cradle_only | solenoid_only

show_housing_reference = true;
show_frame = true;
show_solenoid_cradle = true;
show_centerlines = true;
show_solenoid_reference = true;

// Bridge that joins frame and cradle into one printable part.
bridge_enable = true;
frame_base_t_local = 4.5;          // base frame thickness in sagemcom_meter_clamp.scad
cradle_front_overhang_local = 0.5; // front overhang from solenoid_only.scad (z_min = -0.5)
frame_to_cradle_overlap_z = 2.5;   // deeper overlap into cradle for higher load transfer
frame_extension_join_overlap = 0.12; // slight overlap at frame/extension interface
local_extrude_margin_x = 3.0;      // local extension margin around cradle footprint (X)
local_extrude_margin_y = 3.0;      // local extension margin around cradle footprint (Y)

// Cradle footprint estimates from solenoid_only.scad defaults.
cradle_outer_x_est = 24.2;
cradle_outer_y_min_est = -10.0;
cradle_outer_y_max_est = 7.8;

// Explicit keepout for cradle inner channel (prevents bridge intruding inside cradle).
cradle_inner_x_est = 19.4;
cradle_inner_y_est = 16.4;
cradle_inner_z_min_est = -0.5;
cradle_inner_z_max_est = 31.4;
bridge_inner_keepout_margin = 0.4;

// ---------------------------------------------------------------------------
// Meter/button alignment inputs
// Keep these in sync with sagemcom_meter_clamp.scad when you update that file.
// ---------------------------------------------------------------------------

housing_w_local = 58;
housing_h_local = 92;
button_x_from_right_local = 13.6; // measured
button_x_from_left_local = housing_w_local - button_x_from_right_local;
mirror_button_x_local = false;
button_y_local = 16;
button_stickout_local = 2;
housing_ref_top_z_local = 0.04;

// Solenoid press tuning
button_press_travel_local = 1.0; // target button press depth
solenoid_press_margin_local = 0.1; // slight extra to ensure reliable actuation

// Fine placement trims (for real-world fit tweaking)
mount_x_offset = 0;
mount_y_offset = 0;
mount_z_offset = 0;
solenoid_yaw_deg = 0; // rotate around plunger axis if needed

// ---------------------------------------------------------------------------
// Solenoid values (matching solenoid_only.scad defaults)
// ---------------------------------------------------------------------------

solenoid_front_rest_local = 12;
solenoid_front_extended_local = 17;

// ---------------------------------------------------------------------------
// Derived placement
// ---------------------------------------------------------------------------

button_x_local = -housing_w_local / 2
    + (mirror_button_x_local ? (housing_w_local - button_x_from_left_local) : button_x_from_left_local);
button_y_world = -housing_h_local / 2 + button_y_local;
button_top_z_world = housing_ref_top_z_local + button_stickout_local;

solenoid_stroke_local = max(0, solenoid_front_extended_local - solenoid_front_rest_local);
solenoid_rest_gap_local = max(
    0,
    solenoid_stroke_local - button_press_travel_local - solenoid_press_margin_local
);
solenoid_front_z_world = button_top_z_world + solenoid_rest_gap_local + solenoid_front_rest_local;

solenoid_mount_pos = [
    button_x_local + mount_x_offset,
    button_y_world + mount_y_offset,
    solenoid_front_z_world + mount_z_offset
];

// ---------------------------------------------------------------------------
// Scene modules
// ---------------------------------------------------------------------------

module meter_scene() {
    if (show_housing_reference)
        housing_reference();

    if (show_frame)
        color([0.95, 0.7, 0.1, 0.78])
            button_frame_base();

    if (show_centerlines) {
        if (show_housing_reference)
            housing_centerlines();
        if (show_frame)
            frame_centerlines();
    }
}

module placed_solenoid_cradle() {
    color([0.22, 0.30, 0.40, 1.0])
        translate(solenoid_mount_pos)
            rotate([0, 0, solenoid_yaw_deg])
                solenoid_cradle_u();
}

module placed_solenoid_reference() {
    translate(solenoid_mount_pos)
        rotate([0, 0, solenoid_yaw_deg])
            solenoid();
}

module frame_to_cradle_bridge() {
    if (bridge_enable) {
        // Raise full frame profile in Z until it overlaps the cradle.
        // This replaces ribs with a monolithic vertical frame extension.
        cradle_min_z_world = solenoid_mount_pos[2] - cradle_front_overhang_local;
        extension_top_z = cradle_min_z_world + frame_to_cradle_overlap_z;
        extension_h = max(0, extension_top_z - frame_base_t_local);

        if (extension_h > 0.01) {
            patch_w = cradle_outer_x_est + 2 * local_extrude_margin_x;
            patch_h = (cradle_outer_y_max_est - cradle_outer_y_min_est) + 2 * local_extrude_margin_y;
            patch_center_y = (cradle_outer_y_min_est + cradle_outer_y_max_est) / 2;
            inner_keepout_x = cradle_inner_x_est + 2 * bridge_inner_keepout_margin;
            inner_keepout_y = cradle_inner_y_est + 2 * bridge_inner_keepout_margin;
            inner_keepout_z = (cradle_inner_z_max_est - cradle_inner_z_min_est) + 2 * bridge_inner_keepout_margin;
            inner_keepout_zc = (cradle_inner_z_min_est + cradle_inner_z_max_est) / 2;

            difference() {
                translate([0, 0, frame_base_t_local - frame_extension_join_overlap])
                    linear_extrude(height = extension_h + frame_extension_join_overlap)
                        intersection() {
                            projection(cut = true)
                                button_frame_base();
                            translate([solenoid_mount_pos[0], solenoid_mount_pos[1] + patch_center_y])
                                square([patch_w, patch_h], center = true);
                        }

                // Carve out cradle inner channel + margin to prevent any intrusion.
                translate(solenoid_mount_pos)
                    rotate([0, 0, solenoid_yaw_deg])
                        translate([0, 0, inner_keepout_zc])
                            cube([inner_keepout_x, inner_keepout_y, inner_keepout_z], center = true);
            }
        }
    }
}

module combined_preview() {
    meter_scene();
    if (show_solenoid_cradle)
        placed_solenoid_cradle();
    if (show_frame && show_solenoid_cradle)
        color([0.88, 0.56, 0.16, 1.0])
            frame_to_cradle_bridge();

    if (show_solenoid_reference)
        placed_solenoid_reference();
}

module combined_printable() {
    union() {
        if (show_frame)
            button_frame_base();
        if (show_solenoid_cradle)
            placed_solenoid_cradle();
        if (show_frame && show_solenoid_cradle)
            frame_to_cradle_bridge();
    }
}

// ---------------------------------------------------------------------------
// Render selector
// ---------------------------------------------------------------------------

if (part_to_render == "combined_preview")
    combined_preview();
else if (part_to_render == "combined_printable")
    combined_printable();
else if (part_to_render == "frame_only")
    if (show_frame)
        color([0.95, 0.7, 0.1, 0.78])
            button_frame_base();
else if (part_to_render == "cradle_only")
    if (show_solenoid_cradle)
        placed_solenoid_cradle();
else if (part_to_render == "solenoid_only")
    if (show_solenoid_reference)
        placed_solenoid_reference();
